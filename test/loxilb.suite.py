#!/usr/bin/env python3

import sys
import logging
import math

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []

    for T in ["faui49easy4"]:
        for i in range(0, 1):
            suite.append({
                "bench_script": "loxilb",
                "boot": {},
                "run": {
                    "T": T,
                    "OSE_CPUFREQ": "max",
                },
            })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
