#!/usr/bin/env python3

import sys
import logging
import math

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []

    for T in ["faui49easy6", "faui49easy7"]:
        for i in range(0, 2):
            suite.append({
                "bench_script": "workload-perf",
                "boot": {},
                "run": {
                    "T": T,
                    "CPUFREQ": "max",
                    "WORKLOAD": "sleep " + str(i),
                },
            })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
