#!/usr/bin/env python3

import sys
import logging
import math

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"
    configs = [
        (priv, "kernel.bpf_stats_enabled=1 net.core.bpf_jit_harden=0", "HEAD-dirty"),
        (priv, "kernel.bpf_stats_enabled=1 kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=2", "HEAD-dirty"),
        (priv, "kernel.bpf_stats_enabled=1 kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=0", "HEAD-dirty"),

        # TODO: fix loxilb?: ERR:  2023/11/23 17:17:28 ebpf load - 3 error
        (priv, "kernel.bpf_stats_enabled=1 kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
    ]

    for T in ["faui49easy4"]:
        for _i in range(0, 1):
            for (_ca, sc, b) in configs:
                suite.append({
                    "bench_script": "loxilb",
                    "boot": {
                        "LINUX_GIT_CHECKOUT": b,
                    },
                    "run": {
                        "T": T,
                        "OSE_CPUFREQ": "base",
                        "OSE_SYSCTL": sc,
                    },
                })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
