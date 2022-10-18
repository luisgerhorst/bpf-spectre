#!/usr/bin/env python3

import argparse
import shutil
import sys
from pathlib import Path
import yaml # pyaml
import logging
import string
import pandas as pd

def parseargs():
    parser = argparse.ArgumentParser()
    parser.add_argument('output', type=str)
    parser.add_argument('log', type=str) # spectector log
    parser.add_argument('source', type=str)
    parser.add_argument('perf', type=str)
    return parser.parse_args()

def main():
    logging.basicConfig(level=logging.DEBUG)
    args = parseargs()

    log = Path(args.log).read_text()
    source = Path(args.source).read_text()

    spectector_result = "NA"
    if log.__contains__("[program is safe]"):
        spectector_result = "safe"
    if log.__contains__("[program is unsafe]"):
        assert spectector_result == "NA"
        spectector_result = "unsafe"

    spectector_problem = "NA"
    if log.__contains__("{ERROR:"):
        assert spectector_result == "NA"
        spectector_result = "problem"
        spectector_problem = "error"
    if log.__contains__("WARNING: Pass through an unsupported instruction!"):
        spectector_result = "problem"
        spectector_problem = "unsupported_instruction"

    test_result = "NA"
    if source.__contains__("#![program is safe]"):
        if spectector_result == "safe":
            test_result = "success"
        if spectector_result == "unsafe":
            test_result = "failed"
    if source.__contains__("#![program is unsafe]"):
        if spectector_result == "safe":
            test_result = "failed"
        if spectector_result == "unsafe":
            test_result = "success"

    df = {
        "source": args.source,
        "spectector_result": spectector_result,
        "spectector_problem": spectector_problem,
        "test_result": test_result,
    }

    perf = pd.read_csv(
        Path(args.perf), sep=",", comment="#",
        names = ["counter_value", "counter_unit", "counter_name", "counter_run_time", "counter_run_time_perc", "metric_value", "metric_unit"]
    )
    for _i, row in perf.iterrows():
        counter_unit_suffix = "" if not isinstance(row.counter_unit, str) else "_" + row.counter_unit
        counter_name = str(row.counter_name).lower().replace("-", "_").replace(":", "_")
        df["perf_" + counter_name + counter_unit_suffix] = row.counter_value
        df["perf_counter_run_time_" + counter_name] = row.counter_run_time
        df["perf_counter_run_time_perc_" + counter_name] = row.counter_run_time_perc
        # Perf may use a different unit here unpredictably (M vs G):
        #
        # if isinstance(row.metric_unit, str):
        #     mu = str(row.metric_unit).lower().replace(" ", "_").replace("/", "p")
        #     df["perf_" + counter_name + "_" + mu] = row.metric_value

    with open(Path(args.output), "w") as output_file:
        yaml.dump(df, output_file)

if __name__ == '__main__':
    main()
