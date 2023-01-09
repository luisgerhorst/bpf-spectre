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

    raw_dir = Path(os.getenv("BENCHRUN_DATA", default="../bench/.data"))
    parser = argparse.ArgumentParser(description="Convert raw benchmark data into tidy tabular format.")
    parser.add_argument("-d", "--data")
    parser.add_argument("-r", "--raw-path", default=raw_dir.joinpath("scratch"))
    args = parser.parse_args()
    raw_path = Path(args.raw_path if args.data is None else raw_dir.joinpath(args.data))
    tidy_path = Path(os.getenv("TIDY", default=".tidy/" + raw_path.name + ".tsv.gz"))

    tidy_tests = []

    # Sort tests to allow for easier debugging.
    for test_path in sorted(raw_path.iterdir()):
        if not test_path.joinpath("test-run.yaml").exists():
            continue;
        burst = int(test_path.joinpath("burst_len").read_text())
        for burst_pos in range(0, burst):
            df = tidy_workload(test_path, burst_pos)
            df["burst_pos"] = burst_pos
            df = tidy_test_run_yaml(test_path, df)
            tidy_tests.append(df)

    tidy_df = pd.concat(tidy_tests)

    logging.debug("\n%s", tidy_df)
    tidy_path.parent.mkdir(parents=True, exist_ok=True)
    tidy_df.to_csv(tidy_path, sep="\t")

def tidy_workload(test_path, burst_pos):
    exitcode = test_path.joinpath("workload-exitcode").read_text()
    df = pd.DataFrame({
        "test_foldername": [test_path.name],
        "workload_exitcode": [exitcode]
    })

    if exitcode != "0":
        return df;

    perf = pd.read_csv(
        test_path.joinpath("workload/%d.perf" % burst_pos), sep=",", comment="#",
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

def tidy_test_run_yaml(test_path, df):
    with open(test_path.joinpath("test-run.yaml")) as test_run_yaml:
        test_run = yaml.safe_load(test_run_yaml)
        df = yaml_to_df(df, "test", test_run)
    return df

def yaml_to_df(df, prefix, value):
    sep = "_"
    if isinstance(value, dict):
        for subkey, subvalue in value.items():
            df = yaml_to_df(df, prefix + sep + subkey, subvalue)
    elif isinstance(value, list):
        for i, subvalue in enumerate(value):
            df = yaml_to_df(df, prefix + sep + str(i), subvalue)
        df[prefix] = " ".join(map(str, value))
    else:
        df[prefix] = value
    return df

if __name__ == "__main__":
    main()
