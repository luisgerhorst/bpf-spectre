#!/usr/bin/env python3

import sys
import logging
import math

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []

    for T in ["qemu-debian"]:
        for i in range(0, 10):
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
