#!/usr/bin/env python3

import sys
import logging
import math
import subprocess
from pathlib import Path

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []

    T="qemu-debian"

    priv="--drop="
    unpriv="--drop=cap_sys_admin --drop=cap_perfmon"

    priv_spec_mit="configs/priv-spec-mit.defconfig"

    # TODO: Also test with/without /proc/sys/net/core/bpf_jit_harden set.

    # 'bench -l' dump from Linux v6.2.0-rc1.
    avail_benchs = ["count-global", "count-local", "rename-base", "rename-kprobe",
                    "rename-kretprobe", "rename-rawtp", "rename-fentry", "rename-fexit", "trig-base", "trig-tp",
                    "trig-rawtp", "trig-kprobe", "trig-fentry",
                    "trig-fentry-sleep", "trig-fmodret", "trig-uprobe-base",
                    "trig-uprobe-with-nop", "trig-uretprobe-with-nop",
                    "trig-uprobe-without-nop", "trig-uretprobe-without-nop",
                    # "rb-libbpf",
                    # "rb-custom",
                    # "pb-libbpf", "pb-custom",
                    # "bloom-lookup", "bloom-update", "bloom-false-positive",
                    # "hashmap-without-bloom",
                    # "hashmap-with-bloom",
                    # "bpf-loop",
                    # "strncmp-no-helper", "strncmp-helper",
                    "bpf-hashmap-ful-update",
                    # "local-storage-cache-seq-get",
                    # "local-storage-cache-int-get",
                    # BUG: locked up easy6 "local-storage-cache-hashmap-control",
                    # "local-storage-tasks-trace"
                    ]

    bpf_bench = "../target_prefix/linux-src/tools/testing/selftests/bpf/bench"

    for args in [# "-p16 -c8 count-local",
                 # "-p16 -c8 count-global"
                 ] + avail_benchs:
        for mcs in [priv_spec_mit, ""]:
            suite.append({
                "bench_script": "workload-perf",
                "boot": {
                    "MERGE_CONFIGS": mcs
                },
                "run": {
                    "T": T,
                    "CPUFREQ": "max",
                    "PERF_FLAGS": "--all-cpus",
                    "WORKLOAD": bpf_bench + " " + args,
                },
            })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
