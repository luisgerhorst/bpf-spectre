#!/usr/bin/env python3

import sys
import os
import datetime
import subprocess
import urllib.parse
from pathlib import Path
import logging
import argparse
import random
import time
import copy

import yaml # Install with 'pip install pyyaml'
from etaprogress.progress import ProgressBar

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite_path, suite_run_path, reps, burst_len = parse_args()
    suite_dir = Path(os.path.dirname(suite_path))

    subprocess.run(["make", suite_path], check=True)
    suite = None
    with open(suite_path) as suite_yaml:
        suite = yaml.safe_load(suite_yaml)

    # $ apt-get install trash-cli
    if suite_run_path.is_dir():
        subprocess.run(["trash", suite_run_path], check=True)

    suite_run_path.mkdir(parents=True)

    suite_log_tee = subprocess.Popen(["tee", suite_run_path.joinpath("suite-run.log")], stdin=subprocess.PIPE)
    os.dup2(suite_log_tee.stdin.fileno(), sys.stdout.fileno())
    os.dup2(suite_log_tee.stdin.fileno(), sys.stderr.fileno())

    run_suite(suite_dir, suite_run_path, suite, reps, burst_len)

def parse_args():
    raw_dir = Path(os.getenv("BENCHRUN_DATA", default="../eval/.raw"))

    parser = argparse.ArgumentParser(description="Run each benchmark burst_len times in a row, repeat suite rep times.")
    parser.add_argument("-s", "--suite")
    parser.add_argument("-n", "--data-name", help="Suffix appended to auto-generated path.")
    parser.add_argument("-p", "--data-path", help="Relative to BENCHRUN_DATA. For example, set this to 'scratch' for test-runs.")
    parser.add_argument("-r", "--reps", default=1, type=int)
    parser.add_argument("-b", "--burst-len", default=2, type=int)
    parser.add_argument("--random-seed", default=0, type=int)
    args = parser.parse_args()

    # Allow reproducible shuffling of the suite.
    random.seed(args.random_seed)

    suite_path = Path(".build/" + args.suite + ".yaml")
    suite_run_path = Path(raw_dir.joinpath(
        "{}_{}{}".format(
            datetime.datetime.now().strftime("%y-%m-%d_%H-%M"),
            args.suite,
            "_" + args.data_name if args.data_name is not None else "",
        ) if args.data_path is None else args.data_path))

    return suite_path, suite_run_path, args.reps, args.burst_len

def run_suite(suite_dir, suite_run_path, suite, reps, burst_len):
    i = 0
    bar = ProgressBar(reps * len(suite), max_width=40)
    for rep in range(0, reps):
        random.shuffle(suite)
        # Avoid reboots due to boot param. changes:
        suite = sorted(suite, key=lambda bench:yaml.dump(bench['boot']))
        for bench in suite:
            bar.numerator = i
            print("%s: %s" % (bar, bench), end="\n")
            sys.stdout.flush()
            bench_list = [bench["bench_script"]] + list(bench["boot"].values()) + list(bench["run"].values())
            bench_foldername = '{:04d}-{}'.format(i, '-'.join(map(urllib.parse.quote_plus, map(str, bench_list))))
            run_bench(suite_dir, suite_run_path.joinpath(bench_foldername[0:128]), bench, burst_len)
            i += 1

def run_bench(suite_dir, bench_run_data, bench, burst_len):
    bench_run_data.mkdir()

    with subprocess.Popen(["tee", bench_run_data.joinpath("bench-run.log")], stdin=subprocess.PIPE) as bench_log_tee:
        subproc_env = os.environ.copy()
        for name, value in bench['boot'].items():
            subproc_env[name] = value
        for name, value in bench['run'].items():
            subproc_env[name] = value
        # Sets up the target system for evaluation and runs the benchmark.
        subprocess.run(
            [os.getcwd() / Path("bench-" + bench["bench_script"]),
             bench_run_data, str(burst_len)],
            env=subproc_env,
            stdout=bench_log_tee.stdin, stderr=bench_log_tee.stdin,
            check=True
        )

    bench_run_data.joinpath("burst_len").write_text(str(burst_len))

    with open(bench_run_data.joinpath("bench-run.yaml"), "w") as bench_run_yaml:
        bench_cp = copy.deepcopy(bench)

        # Merge boot/run for eval, were only needed to avoid reboots here.
        bench_run = {}
        bench_run.update(bench_cp.pop('boot'))
        bench_run.update(bench_cp.pop('run'))
        bench_run.update(bench_cp)

        bench_run["date"] = datetime.datetime.now().isoformat()
        bench_run["burst_len"] = burst_len
        yaml.dump(bench_run, bench_run_yaml)

if __name__ == "__main__":
    main()
