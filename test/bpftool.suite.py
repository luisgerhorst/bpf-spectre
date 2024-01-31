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

    for p in Path("../src/bpf-samples/.build/").glob("*.bpf.o"):
        p.unlink()
    subprocess.run(["make",
                    "-j", str(multiprocessing.cpu_count()),
                    "-C", "../src/bpf-samples", "all"],
                   check=True, stdout=sys.stderr.buffer)

    T = os.getenv("T", default="faui49easy1")

    suite = []
    append_T(suite, T)
    yaml.dump(suite, sys.stdout)

def append_T(suite, T):
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"
    sc_always = "" # in target-scripts
    configs = [
        (priv, "", "bpf-spectre-baseline"), # Baseline (Best Performance, Very Unsafe)
        (priv, "kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=2", "bpf-spectre-baseline"), # Baseline (No Load Failures, Unsafe)
        (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "bpf-spectre-baseline"), # Baseline (Load Failures, Safe)
        (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
    ]

    # Used to avoid trying to find the type by trail/error when no type will
    # work. Also prevents false guesses.
    prog_types = {
        "llb_ebpf_main": "tc",
        "llb_ebpf_emain": "tc",
        "llb_kern_mon": "perf_event",
        "llb_xdp_main": "xdp.frags/devmap",
        "cilium_sock": "INFERRED",
    }

    # All programs:
    for prog_path in Path("../src/bpf-samples/.build/").glob("*.bpf.o"):
        prog = Path(Path(prog_path.name).stem).stem # basename, without .bpf.o

        # Skip priv_spec_mit with unpriv user because it will be the same as
        # regular unpriv.
        for (ca, sc, b) in configs:
            suite.append({
                "bench_script": "bpftool",
                "boot": {
                    "LINUX_GIT_CHECKOUT": b,
                },
                "run": {
                    "T": T,
                    "MERGE_CONFIGS": "",
                    "OSE_CPUFREQ": "base",
                    "OSE_CAPSH_ARGS": ca,
                    "OSE_SYSCTL": sc_always + " " + sc,
                    "OSE_BPF_OBJ": prog + ".bpf.o",
                    "OSE_BPFTOOL_TYPE": prog_types.get(prog, ""),
                },
            })

if __name__ == "__main__":
    main()
