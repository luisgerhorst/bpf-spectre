#!/usr/bin/env python3

import sys
import os
from pathlib import Path
import logging
import argparse
import glob
import re
import json

import numpy as np
import pandas as pd
import yaml
# from etaprogress.progress import ProgressBar
from joblib import Parallel, delayed

def main():
    logging.basicConfig(level=logging.DEBUG)

    raw_dir = Path(os.getenv("TESTRUN_DATA", default=".raw"))
    parser = argparse.ArgumentParser(description="Convert raw benchmark data into tidy tabular format: https://tidyr.tidyverse.org/articles/tidy-data.html")
    parser.add_argument("-d", "--data")
    parser.add_argument("-r", "--raw-path", default=raw_dir.joinpath("scratch"))
    args = parser.parse_args()
    raw_path = Path(args.raw_path if args.data is None else raw_dir.joinpath(args.data))
    tidy_path = Path(os.getenv("TIDY", default=".tidy/" + raw_path.name + ".tsv.gz"))

    # Sort tests to allow for easier debugging.
    brps = sorted(raw_path.iterdir())

    br_dfs = Parallel(n_jobs=-1, verbose=1)(delayed(bench_run_df)(brp) for brp in brps)
    # br_dfs = []
    # for brp in brps:
    #    br_dfs += [bench_run_df(brp)]

    tidy_df = pd_concat_rows(br_dfs)
    tidy_df["data"] = raw_path.name

    logging.debug("\n%s", tidy_df)
    tidy_path.parent.mkdir(parents=True, exist_ok=True)
    tidy_df.to_csv(tidy_path, sep="\t", index=False)

def pd_concat_cols(l):
    return pd.concat(l, axis='columns', verify_integrity=True)

def pd_concat_rows(l):
    return pd.concat(l, axis='index')

def bench_run_df(bench_run_path):
    tidy_dfs = []

    if not bench_run_path.joinpath("bench-run.yaml").exists():
        return pd.DataFrame()

    values = load_values(bench_run_path)
    tidy_values = pd.DataFrame(load_tidy_values(bench_run_path), index=[0])
    yaml = load_yaml(bench_run_path)

    burst_len = int(values["burst_len"])
    for burst_pos in range(0, burst_len):
        df = pd_concat_cols([
            dict_into_df(
                tidy_bench_run(bench_run_path, values, yaml, burst_pos),
                None, yaml
            ),
            tidy_values,
            pd.DataFrame({
                "bench_run_name": bench_run_path.name,
                "burst_pos": burst_pos
            }, index=[0])
        ])
        tidy_dfs.append(df)
    return pd_concat_rows(tidy_dfs)

def tidy_bench_run(bench_run_path, values, yaml, burst_pos):
    if yaml["bench_script"] == "workload-perf":
        return tidy_workload_perf(bench_run_path, burst_pos, yaml, values)
    elif yaml["bench_script"] == "tracer" or yaml["bench_script"] == "loxilb":
        dfs = [
            tidy_workload_perf(bench_run_path, burst_pos, yaml, values),
            tidy_bpf_tracer(bench_run_path, burst_pos, yaml, values)
        ]
        if yaml["bench_script"] == "loxilb":
            if yaml["OSE_LOXILB_VALIDATION"] == "netperf":
                dfs += tidy_netperf(bench_run_path, burst_pos,
                                    int(yaml["OSE_LOXILB_CLIENTS"]))
            elif yaml["OSE_LOXILB_VALIDATION"] == "wrk":
                dfs += tidy_wrk_latency(bench_run_path, burst_pos)
            else:
                dfs += tidy_loxilb_iperf(bench_run_path, burst_pos)
                dfs += tidy_loxilb_iperf3(bench_run_path, burst_pos, suffix="tcp")
                dfs += tidy_loxilb_iperf3(bench_run_path, burst_pos, suffix="sctp")
        return pd_concat_cols(dfs)
    else:
        return pd_concat_cols([
            tidy_bpftool(bench_run_path, values, yaml, burst_pos),
            tidy_bpftool_loadall_log(bench_run_path, values)
        ])

def tidy_netperf(brp, burst_pos, nr_clients):
    dfs = []
    for i in range(0, nr_clients):
        client_obs = pd.read_csv(
            brp.joinpath(f'workload/{burst_pos}.netperf-client.{i}.log'),
            sep='\s+',
            skiprows=[0, 1, 3, 4],
            header=0,
            usecols=["Elapsed", "Trans."],
            engine='python',
            skipfooter=1,
            on_bad_lines='skip',
        ).add_prefix("netperf_")
        dfs.append(client_obs)
    workload_observation = pd_concat_rows(dfs).agg(['sum']).reset_index(drop=True)
    return [workload_observation]

def tidy_loxilb_iperf(brp, burst_pos):
    try:
        iperf = pd.read_csv(
            brp.joinpath("workload/%d.iperf-client.csv" % burst_pos),
            sep=",",
            names=[
                # yay, docs https://serverfault.com/questions/566737/iperf-csv-output-format
                "timestamp",
                "source_address",
                "source_port",
                "destination_address",
                "destination_port",
                "id",
                "interval",
                "transferred_bytes",
                "bits_per_second"
            ],
        )
        iperf = iperf.drop(
            axis='columns',
            labels=[
                'timestamp', 'source_address', 'source_port',
                'destination_address', 'destination_port', 'interval'
            ]
        ).agg(['sum']).reset_index(drop=True).add_prefix('iperf_')
        return [iperf]
    except FileNotFoundError as e:
        return [pd.DataFrame({ "iperf_bits_per_second": ["NA"] })]

def tidy_loxilb_iperf3(brp, burst_pos, suffix="sctp"):
    try:
        iperf3 = json.load(brp.joinpath(f'workload/{burst_pos}.iperf3-{suffix}-client.json').open())
        return tidy_iperf3_json(iperf3, "")
    except FileNotFoundError as e:
        return []
    except KeyError as e:
        print(e, file=sys.stderr)
        return []

def tidy_wrk_latency(brp, burst_pos):
    wrk_log = brp.joinpath(f'workload/{burst_pos}.wrk-latency.log').read_text().splitlines()
    df = pd.DataFrame({"wrk_latency": ["true"]})
    latency = False
    for line in wrk_log:
        tokens = list(filter(lambda x: x != '', re.split(r"\s+", line)))
        if len(tokens) > 0 and tokens[0] == "Latency":
            latency = True
        elif len(tokens) > 0 and tokens[0] == "Detailed":
            latency = False
        elif latency and len(tokens) == 2:
            latency_ms = float(re.split(r"[a-z]+", tokens[1])[0])
            if "us" in tokens[1]:
                latency_ms /= 1000
            df["wrk_latency_" + tokens[0] + "_ms"] = [latency_ms]
        elif not latency and len(tokens) == 2 and tokens[0] == "Requests/sec:":
            df["wrk_requests_per_sec"] = float(tokens[1])
        else:
            logging.debug(line)
    return [df]

def tidy_iperf3_json(iperf3, suffix):
    return [
        dict_into_df(pd.DataFrame({"iperf3_json": ["true"]}),
                     f'iperf3_{suffix}_start_test_start',
                     iperf3["start"]["test_start"]),
        dict_into_df(pd.DataFrame({"iperf3_json_1": ["true"]}),
                     f'iperf3_{suffix}_end_sum_received',
                     iperf3["end"]["sum_received"]),
        dict_into_df(pd.DataFrame({"iperf3_json_2": ["true"]}),
                     f'iperf3_{suffix}_end_cpu_utilization_percent',
                     iperf3["end"]["cpu_utilization_percent"])
    ]


def load_values(bench_run_path):
    d = {}
    for key_path in bench_run_path.joinpath("values").glob("*"):
        d[key_path.name] = key_path.read_text().rstrip()
    return d

def load_tidy_values(bench_run_path):
    d = {}
    for key_path in bench_run_path.joinpath("values").glob("*"):
        if key_path.name.startswith("bpftool_run_exitcode."):
            continue
        d[key_path.name] = key_path.read_text().rstrip()
    return d

def load_yaml(bench_run_path):
    with open(bench_run_path.joinpath("bench-run.yaml")) as bench_run_yaml:
        return yaml.safe_load(bench_run_yaml)

def dict_into_df(df, prefix, value):
    sep = "_"
    ps = "" if prefix is None else prefix + sep
    if isinstance(value, dict):
        for subkey, subvalue in value.items():
            df = dict_into_df(df, ps + subkey, subvalue)
    elif isinstance(value, list):
        for i, subvalue in enumerate(value):
            df = dict_into_df(df, ps + str(i), subvalue)
        df = df.copy()
        df[prefix] = " ".join(map(str, value))
    else:
        df = df.copy()
        df[prefix] = value
    return df

def tidy_bpftool_loadall_log(brp, values):
    d = pd.DataFrame({ "verification_time_usec": ["NA"] })

    lines = None
    try:
        p = values["bpftool_loadall_path"]
        lines = brp.joinpath("bpftool/" + p + ".log").read_text().splitlines()
    except:
        # Fallback for old data formats:
        if values["bpftool_loadall_type"] == "NA":
            lines = brp.joinpath("bpftool/loadall.log").read_text().splitlines()
        else:
            return d

        # TODO: handle multiple funcs
        #
        # Validating f8() func#1...
        # 2: R1=ctx(off=0,imm=0) R10=fp0
        # ; return f7(skb);
        # 2: (85) call pc+1
        # Func#2 is global and valid. Skipping.
        # 3: R0_w=scalar()
        # ; return f7(skb);
        # 3: (95) exit
        # Func#1 is safe for any args that match its prototype
        # Validating f7() func#2...
        # 4: R1=ctx(off=0,imm=0) R10=fp0
    speculative = False         # assume insn 0 is invoked non-speculatively
    l_prev = "NA"
    for l in lines:
        if re.match(r"^from [0-9]+ to [0-9]+.*:.*$", l) is not None:
            speculative = "(speculative execution)" in l
        if re.match(r"^verification time .+ usec$", l) is not None:
            d["verification_time_usec"] = l.split()[2]
            insn_safe = re.match(r"^[0-9]+: safe$", l_prev) is not None
            vblock_safe = re.match(r"^from [0-9]+ to [0-9]+.*: safe$", l_prev) is not None
            exit_reached = re.match(r"^[0-9]+: \(.+\) exit$", l_prev) is not None
            if insn_safe or vblock_safe or exit_reached:
                d["verification_error_msg"] = "NA"
                d["verification_error_speculative"] = "NA"
            else:
                d["verification_error_msg"] = l_prev
                d["verification_error_speculative"] = speculative
        if re.match(r"^libbpf: failed to guess program type from ELF section '.+'$", l_prev) is not None:
            if re.match(r"^libbpf: supported section.+ names are: .+$", l) is not None:
                d["bpftool_loadall_error"] = "libbpf: failed to guess program type from ELF section '*'"
                d["bpftool_loadall_error_reason_msg"] = l_prev + "; " + l
        if re.match(r"^Error:.*$", l) is not None:
            d["bpftool_loadall_error"] = l
            d["bpftool_loadall_error_reason_msg"] = l_prev
        l_prev = l
    if values["bpftool_loadall_exitcode"] == "0":
        d["bpftool_loadall_error"] = "NA"
        d["bpftool_loadall_error_reason_msg"] = "NA"
        d["verification_error_msg"] = "NA"
        d["verification_error_speculative"] = "NA"
    return d

def tidy_bpftool(bench_run_path, values, yaml, burst_pos, bpftool_run=True):
    if values["bpftool_loadall_exitcode"] != "0" or "bpftool_progs" not in values:
        # bpftool only exports data for the last repetition (burst_pos == repeat argument).
        return pd.DataFrame({ "observation": ["bench"] })

    dfs = []
    for prog in values["bpftool_progs"].split():
        rec = int(values["bpftool_run_exitcode." + prog])

        df = pd.DataFrame({
            "observation": ["bpftool_prog_run"],
            "bpftool_prog": [prog],
        })

        df = tidy_bpftool_jited_into_df(bench_run_path, prog, df)

        if rec == 0:
            try:
                run_json = json.load(bench_run_path.joinpath("bpftool/run." + prog + "." + str(burst_pos) + ".json").open())
                run_json["duration_ns"] = run_json["duration"] # https://qmonnet.github.io/whirl-offload/2021/09/23/bpftool-features-thread/
                df = dict_into_df(df, "bpftool_run", run_json)
            except json.decoder.JSONDecodeError as e:
                print("%s: %s" % (bench_run_path, e), file=sys.stderr)
                raise e

        dfs.append(df)
    return pd_concat_rows(dfs)

def tidy_bpftool_jited_into_df(brp, prog, df):
    jited = None
    f = "bpftool/jited." + prog + ".json"
    try:
        # Fixup for bpftool's invalid \' escapes in old kernels.
        s = brp.joinpath(f).read_text().replace("\\'", "'")
        jited = json.loads(s)
        # Likely caused by bpftool segfault for some linux test programs.
    except json.decoder.JSONDecodeError as je:
        print("%s/%s: %s" % (brp, f, je), file=sys.stderr)
        df["bpftool_jited_insncnt_total"] = [None]
        return df
        # raise je

    if "error" in jited:
        df["bpftool_jited_insncnt_total"] = [None]
        return df

    # Init actually used fields here, otherwise 0 is NA.
    counts = {}
    for o in ["lfence",           # san. stack slot, SSB
              "rorw", "xorl", "xorq", "shlq", "cmpq", "subq", "addq", "andq", "orq", # ptr-alu-trunc
              "callq", "je", "jne", "movq", "movl" # Generic
              ]:
        counts[o] = 0

    insns = None
    insns_len = None
    try:
        insns = jited[0]["insns"]
        insns_len = len(insns)
        for insn in insns:
            o = insn["operation"]
            counts[o] = counts.get(o, 0) + 1
        for k, v in counts.items():
            df["bpftool_jited_insncnt_" + k] = [v]
    except KeyError as e:
        print("KeyError: %s %s" % (brp, prog), file=sys.stderr)

    df["bpftool_jited_insncnt_total"] = [insns_len]
    return df

def tidy_workload_perf(bench_run_path, burst_pos, yaml, values):
    avail = values["workload_exitcode"] == "0" and values.get("tracer_exitcode", "0") == "0"
    df = pd.DataFrame({ "observation": ["bench.burst" if avail else "bench"] })
    if not avail:
        return df

    if "/tools/testing/selftests/bpf/bench" in yaml.get("WORKLOAD", ""):
        df = tidy_kselftest_bpf_bench(bench_run_path, burst_pos)

    perf = None
    try:
        perf = pd.read_csv(
            bench_run_path.joinpath("workload/%d.perf" % burst_pos), sep=",", comment="#",
            names = ["counter_value", "counter_unit", "counter_name", "counter_run_time", "counter_run_time_perc",
                     "metric_value", "metric_unit"],
        )
    except FileNotFoundError as e:
        print(e, file=sys.stderr)
        return df

    for _i, row in perf.iterrows():
        counter_unit_suffix = "" if not isinstance(row.counter_unit, str) else "_" + row.counter_unit
        counter_name = str(row.counter_name).lower().replace("-", "_").replace(":", "_")
        df["perf_" + counter_name + counter_unit_suffix] = row.counter_value
        df["perf_counter_run_time_" + counter_name] = row.counter_run_time
        df["perf_counter_run_time_perc_" + counter_name] = row.counter_run_time_perc
        if isinstance(row.metric_unit, str):
            mu = str(row.metric_unit).lower().replace(" ", "_").replace("/", "p")
            df["perf_" + counter_name + "_" + mu] = row.metric_value

    return df

# Sums up info accross all loaded BPF programs.
def tidy_bpf_tracer(bench_run_path, burst_pos, yaml, values):
    avail = values["workload_exitcode"] == "0" and values.get("tracer_exitcode", "0") == "0"
    if not avail:
        return pd.DataFrame()

    init_progs = json.load(bench_run_path.joinpath("workload/%d.init.bpftool_prog_show.json" % burst_pos).open())
    progs = json.load(bench_run_path.joinpath("workload/%d.bpftool_prog_show.json" % burst_pos).open())

    # Accumulate json items, skip systemd progs.
    f = ["run_time_ns", "run_cnt", "bytes_jited", "bytes_xlated", "bytes_memlock"]
    d = {}
    insncnt_dfs = []
    for n in f:
        d["bpftool_prog_show_" + n] = [0]
    d["bpftool_prog_show_cnt"] = [0]
    for prog in progs:

        is_init = False
        for ip in init_progs:
            if ip["id"] == prog["id"]:
                assert ip["tag"] == prog["tag"]
                is_init = True
                break
        if is_init:
            try:
                assert prog["pids"][0]["comm"] in ["systemd", "loxilb"]
            except KeyError as e:
                pass
            continue

        for n in f:
            try:
                d["bpftool_prog_show_" + n][0] = d["bpftool_prog_show_" + n][0] + int(prog[n])
            except KeyError as e:
                pass
        d["bpftool_prog_show_cnt"][0] += 1

        prog_id = str(prog["id"])
        insncnt_df = tidy_bpftool_jited_into_df(bench_run_path, prog_id, pd.DataFrame()).reset_index(drop=True)
        insncnt_dfs.append(insncnt_df)
    if d["bpftool_prog_show_cnt"][0] == 0:
        return pd.DataFrame(d, index=[0])
    insncnts_df = pd_concat_rows(insncnt_dfs)
    insncnts_df = insncnts_df.agg(['sum']).reset_index(drop=True)

    df = pd_concat_cols([
        pd.DataFrame(d, index=[0]),
        insncnts_df
    ])
    return df

def tidy_kselftest_bpf_bench(br_path, burst_pos):
    df = pd.DataFrame({ "observation": ["workload_run"] })
    try:
        lines = br_path.joinpath("workload/%d.stdout" % burst_pos).read_text().splitlines()
    except:
        lines = []
    for line in lines:
        colon_tokens = line.split(":")
        if colon_tokens[0] == "Summary":
            measurements = colon_tokens[1]
            for measurement in measurements.split(","):
                [name_value, var_unit_etc] = measurement.split("±")

                n = name_value.split()[0:-1]
                name = "_".join(n)
                value = name_value.split()[-1]

                var_unit = var_unit_etc.split()[0]
                var = re.split('[^0-9\.]+', var_unit)[0]
                unit = re.split('\d+', var_unit)[2]

                u = str(unit).lower().replace(" ", "_").replace("/", "p")
                df["bpf_bench_summary_" + name + "_" + u] = value
                df["bpf_bench_summary_" + name + "_" + u + "_variation"] = var
            break
    return df

if __name__ == "__main__":
    main()
