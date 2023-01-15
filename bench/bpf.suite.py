#!/usr/bin/env python3

import sys
import logging
import math

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []

    priv="--drop="
    unpriv="--drop=cap_sys_admin --drop=cap_perfmon"

    for T in ["faui49easy7"]:
        for i in range(0, 2):
            suite.append({
                "bench_script": "bpftool",
                # TODO: Allow setting kernel Kconfig options here (priv. spectre mit.).
                "boot": {},
                "run": {
                    "T": T,
                    "CPUFREQ": "max",
                    "CAPSH_ARGS": priv,
                    "BPF_PROG": "lbe_sockfilter",
                },
            })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
