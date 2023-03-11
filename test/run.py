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
import time
import shutil

import yaml # Install with 'pip install pyyaml'
from etaprogress.progress import ProgressBar

def main():
    logging.basicConfig(level=logging.DEBUG)

    args, suite_path, suite_run_path = parse_args()
    suite_dir = Path(os.path.dirname(suite_path))

    subprocess.run(["make", suite_path], check=True, env=os.environ.copy())
    suite = None
    with open(suite_path) as suite_yaml:
        suite = yaml.safe_load(suite_yaml)

    # $ apt-get install trash-cli
    if suite_run_path.is_dir():
        subprocess.run(["trash", suite_run_path], check=True)

    suite_run_path.mkdir(parents=True)
    shutil.copy(suite_path, suite_run_path.joinpath("suite.yaml"))

    suite_log_tee = subprocess.Popen(["tee", suite_run_path.joinpath("suite-run.log")], stdin=subprocess.PIPE)
    os.dup2(suite_log_tee.stdin.fileno(), sys.stdout.fileno())
    os.dup2(suite_log_tee.stdin.fileno(), sys.stderr.fileno())

    print(args)
    run_suite(suite_dir, suite_run_path, suite, args.reps, args.burst_len)

    subprocess.run(["make", "-k", "-C", "../data/archive", suite_run_path.name + ".tar.gz"],
                   check=True)

def parse_args():
    raw_dir = Path(os.getenv("TESTRUN_DATA", default="../data/.raw"))

    parser = argparse.ArgumentParser(description="Run each benchmark burst_len times in a row, repeat suite rep times.")
    parser.add_argument("-s", "--suite")
    parser.add_argument("-n", "--data-name", help="Suffix appended to auto-generated path.")
    parser.add_argument("-p", "--data-path", help="Relative to TESTRUN_DATA. For example, set this to 'scratch' for test-runs.")
    parser.add_argument("-r", "--reps", default=1, type=int)
    parser.add_argument("-b", "--burst-len", default=5, type=int)
    parser.add_argument("--random-seed", default=time.time_ns(), type=int)
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

    return args, suite_path, suite_run_path

RETRY_MAX = 10

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
            human_name = urllib.parse.quote_plus('-'.join(map(str, bench_list)).replace("=", "-"))[0:128]
            name = '{:06d}.{}'.format(i, human_name.replace(".", "-"))
            tmp = None
            for retry in range(0, RETRY_MAX):
                tmp = suite_run_path.joinpath("%s.retry-%d.incomplete-bench-run" % (name, retry))
                tmp.mkdir()
                try:
                    run_bench(suite_dir, tmp, bench, burst_len, retry)
                    break
                except subprocess.CalledProcessError as e:
                    if retry == RETRY_MAX-1:
                        raise e
                    time.sleep(retry*60)
            os.rename(tmp, suite_run_path.joinpath("%s.bench-run" % (name)))
            i += 1

def run_bench(suite_dir, bench_run_data, bench, burst_len, retry):
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

    values_dir = bench_run_data.joinpath("values")
    values_dir.mkdir(parents=True, exist_ok=True)
    values_dir.joinpath("burst_len").write_text(str(burst_len))

    with open(bench_run_data.joinpath("bench-run.yaml"), "w") as bench_run_yaml:
        bench_cp = copy.deepcopy(bench)

        # Merge boot/run for eval, were only needed to avoid reboots here.
        bench_run = {}
        bench_run.update(bench_cp.pop('boot'))
        bench_run.update(bench_cp.pop('run'))
        bench_run.update(bench_cp)

        bench_run["retry"] = retry
        bench_run["date"] = datetime.datetime.now().isoformat()
        yaml.dump(bench_run, bench_run_yaml)

if __name__ == "__main__":
    main()
