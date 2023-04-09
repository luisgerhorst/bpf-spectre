#!/usr/bin/env python3

import sys
import logging
import math
import os
import subprocess
from pathlib import Path
import multiprocessing

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    T = os.getenv("T", default="debian.local")

    suite = []
    append_T(suite, T)
    yaml.dump(suite, sys.stdout)

def append_T(suite, T):
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"

    # Skip priv_spec_mit with unpriv user because it will be the same as
    # regular unpriv.
    for (ca, sc, b) in [
            # (unpr, "net.core.bpf_jit_harden=0", "master"),
            # (priv, "net.core.bpf_jit_harden=0", "master"),
            # (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "bpf-spectre"),
            # (priv, "kernel.bpf_spec_v1=2", "bpf-spectre"),
            # (priv, "kernel.bpf_spec_v1=2", "bpf-spectre-v1-nospec~1"),
            # (priv, "kernel.bpf_spec_v1=2", "bpf-spectre-v1-nospec"),
            # (priv, "kernel.bpf_spec_v1=2", "HEAD"),
            (priv, "net.core.bpf_jit_harden=0", "HEAD-dirty"),
            (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
            # (priv, "kernel.bpf_spec_v4=2"),
            # (priv, "net.core.bpf_jit_harden=2"),
    ]:
        suite.append({
            "bench_script": "workload-perf",
            "boot": {
                "LINUX_GIT_CHECKOUT": b,
            },
            "run": {
                "T": T,
                "CPUFREQ": "base",
                "SYSCTL": sc,
                "CAPSH_ARGS": "NA",
                "MERGE_CONFIGS": "",
                "WORKLOAD_PREPARE": "sudo systemctl start memcached",
                "WORKLOAD": "memtier_benchmark",
                "WORKLOAD_CLEANUP": "sudo systemctl disable memcached",
            },
        })

if __name__ == "__main__":
    main()
