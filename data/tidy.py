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

    raw_dir = Path(os.getenv("BENCHRUN_DATA", default=".raw"))
    parser = argparse.ArgumentParser(description="Convert raw benchmark data into tidy tabular format: https://tidyr.tidyverse.org/articles/tidy-data.html")
    parser.add_argument("-d", "--data")
    parser.add_argument("-r", "--raw-path", default=raw_dir.joinpath("scratch"))
    args = parser.parse_args()
    raw_path = Path(args.raw_path if args.data is None else raw_dir.joinpath(args.data))
    tidy_path = Path(os.getenv("TIDY", default=".tidy/" + raw_path.name + ".tsv.gz"))

    # Sort tests to allow for easier debugging.
    brps = sorted(raw_path.iterdir())
    br_dfs = Parallel(n_jobs=-1, verbose=1)(delayed(bench_run_df)(brp) for brp in brps)
    tidy_df = pd.concat(br_dfs)

    logging.debug("\n%s", tidy_df)
    tidy_path.parent.mkdir(parents=True, exist_ok=True)
    tidy_df.to_csv(tidy_path, sep="\t", index=False)

def bench_run_df(bench_run_path):
    tidy_dfs = []

    if not bench_run_path.joinpath("bench-run.yaml").exists():
        return pd.DataFrame()

    values = load_values(bench_run_path)
    yaml = load_yaml(bench_run_path)

    burst_len = int(values["burst_len"])
    for burst_pos in range(0, burst_len):
        df = tidy_bench_run(bench_run_path, values, yaml, burst_pos)
        df = dict_into_df(df, None, yaml)
        df = pd.concat([
            df,
            pd.DataFrame(values, index=[0]),
            pd.DataFrame({
                "bench_run_name": bench_run_path.name,
                "burst_pos": burst_pos
            }, index=[0])
        ], axis=1)
        tidy_dfs.append(df)
    return pd.concat(tidy_dfs)

def load_values(bench_run_path):
    d = {}
    for key_path in bench_run_path.joinpath("values").glob("*"):
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
        df[prefix] = " ".join(map(str, value))
    else:
        df[prefix] = value
    return df

def tidy_bench_run(bench_run_path, values, yaml, burst_pos):
    if yaml["bench_script"] == "workload-perf":
        return tidy_workload_perf(bench_run_path, burst_pos, yaml, values["workload_exitcode"])
    else:
        return tidy_bpftool(bench_run_path, values, yaml, burst_pos)

def tidy_bpftool(bench_run_path, values, yaml, burst_pos):
    if values["bpftool_loadall_exitcode"] != "0" or "bpftool_progs" not in values:
        # bpftool only exports data for the last repetition (burst_pos == repeat argument).
        return pd.DataFrame({ "observation": ["bench_run"] })

    dfs = []
    for prog in values["bpftool_progs"].split():
        rec = int(values["bpftool_run_exitcode." + prog])

        df = pd.DataFrame({
            "observation": ["bpftool_prog_run"],
            "bpftool_prog": [prog],
            "bpftool_run_exitcode": [rec]
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
    return pd.concat(dfs)

def tidy_bpftool_jited_into_df(brp, prog, df):
    jited = None
    try:
        jited = json.load(brp.joinpath("bpftool/jited." + prog + ".json").open())
        # Likely caused by bpftool segfault for some linux test programs.
    except json.decoder.JSONDecodeError as je:
        df["bpftool_jited_insncnt_total"] = [None]
        return df

    # Init actually used fields here, otherwise 0 is NA.
    counts = {}
    for o in ["lfence",           # san. stack slot, SSB
              "rorw", "xorl", "xorq", "shlq", "cmpq", "subq", "addq", "andq", "orq", # ptr-alu-trunc
              "callq", "je", "jne", "movq", "movl" # Generic
              ]:
        counts[o] = 0
    for insn in jited[0]["insns"]:
        o = insn["operation"]
        counts[o] = counts.get(o, 0) + 1
    for k, v in counts.items():
        df["bpftool_jited_insncnt_" + k] = [v]

    df["bpftool_jited_insncnt_total"] = [len(jited[0]["insns"])]
    return df

def tidy_workload_perf(bench_run_path, burst_pos, yaml, exitcode):
    avail = exitcode == "0"
    df = pd.DataFrame({ "observation": ["workload_run" if avail else "bench_run"] })
    if not avail:
        return df

    if "/tools/testing/selftests/bpf/bench" in yaml["WORKLOAD"]:
        df = tidy_kselftest_bpf_bench(bench_run_path, burst_pos)

    perf = pd.read_csv(
        bench_run_path.joinpath("workload/%d.perf" % burst_pos), sep=",", comment="#",
        names = ["counter_value", "counter_unit", "counter_name", "counter_run_time", "counter_run_time_perc",
                 "metric_value", "metric_unit"]
    )
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
