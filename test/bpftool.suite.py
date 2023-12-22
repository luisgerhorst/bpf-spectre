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

    T = os.getenv("T", default="faui49easy2")

    suite = []
    append_T(suite, T)
    yaml.dump(suite, sys.stdout)

def append_T(suite, T):
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"
    sc_always = "kernel.bpf_stats_enabled=1 kernel.bpf_complexity_limit_jmp_seq=16384 kernel.bpf_spec_v1_complexity_limit_jmp_seq=8192"
    configs = [
        (priv, "net.core.bpf_jit_harden=0", "HEAD-dirty"),
        (priv, "kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=2", "HEAD-dirty"),
        (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=0", "HEAD-dirty"),
        (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
    ]

    # Used to avoid having to find the type by trail/error. Also prevents false guesses.
    prog_types = {
        "llb_ebpf_main": "tc",
        "llb_ebpf_emain": "tc",
        "llb_kern_mon": "perf_event",
        "llb_xdp_main": "xdp.frags/devmap",
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
