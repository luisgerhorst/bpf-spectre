#!/usr/bin/env python3

import sys
import os
from pathlib import Path
import logging
import argparse
import glob

import numpy as np
import pandas as pd
import yaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    raw_dir = Path(os.getenv("BENCHRUN_DATA", default=".raw"))
    parser = argparse.ArgumentParser(description="Convert raw benchmark data into tidy tabular format: https://tidyr.tidyverse.org/articles/tidy-data.html")
    parser.add_argument("-d", "--data")
    parser.add_argument("-r", "--raw-path", default=raw_dir.joinpath("scratch"))
    args = parser.parse_args()
    raw_path = Path(args.raw_path if args.data is None else raw_dir.joinpath(args.data))
    tidy_path = Path(os.getenv("TIDY", default=".tidy/" + raw_path.name + ".tsv.gz"))

    tidy_dfs = []

    # Sort tests to allow for easier debugging.
    for bench_run_path in sorted(raw_path.iterdir()):
        if not bench_run_path.joinpath("bench-run.yaml").exists():
            continue;
        values = load_values(bench_run_path)
        yaml = load_yaml(bench_run_path)
        burst_len = int(values["burst_len"])
        for burst_pos in range(0, burst_len):
            df = tidy_bench_run(bench_run_path, values, yaml, burst_pos);
            for key, value in values.items():
                df[key] = value
            df = yaml_into_df(df, None, yaml)
            df["bench_run_name"] = bench_run_path.name
            df["burst_pos"] = burst_pos
            tidy_dfs.append(df)

    tidy_df = pd.concat(tidy_dfs)

    logging.debug("\n%s", tidy_df)
    tidy_path.parent.mkdir(parents=True, exist_ok=True)
    tidy_df.to_csv(tidy_path, sep="\t")

def load_values(bench_run_path):
    d = {}
    for key_path in bench_run_path.joinpath("values").glob("*"):
        d[key_path.name] = key_path.read_text()
    return d

def load_yaml(bench_run_path):
    with open(bench_run_path.joinpath("bench-run.yaml")) as bench_run_yaml:
        return yaml.safe_load(bench_run_yaml)

def yaml_into_df(df, prefix, value):
    sep = "_"
    ps = "" if prefix is None else prefix + sep
    if isinstance(value, dict):
        for subkey, subvalue in value.items():
            df = yaml_into_df(df, ps + subkey, subvalue)
    elif isinstance(value, list):
        for i, subvalue in enumerate(value):
            df = yaml_into_df(df, ps + str(i), subvalue)
        df[prefix] = " ".join(map(str, value))
    else:
        df[prefix] = value
    return df

def tidy_bench_run(bench_run_path, values, yaml, burst_pos):
    if yaml["bench_script"] == "workload-perf":
        return tidy_workload_perf(bench_run_path, burst_pos)
    else:
        return pd.DataFrame({ "dummy": ["dummy"] }) # TODO

def tidy_workload_perf(bench_run_path, burst_pos):
    # TODO: Move to values directory.
    exitcode = bench_run_path.joinpath("workload-exitcode").read_text()
    df = pd.DataFrame({
        "workload_exitcode": [exitcode]
    })

    if exitcode != "0":
        return df;

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

if __name__ == "__main__":
    main()
