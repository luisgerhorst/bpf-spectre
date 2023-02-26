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

    for p in Path("../system/bpf-samples/.build/").glob("*.bpf.o"):
        p.unlink()
    subprocess.run(["make", "-j", str(multiprocessing.cpu_count()), "-C", "../system/bpf-samples", "all"],
                   check=True, stdout=sys.stderr.buffer)

    T = os.getenv("T", default="faui49easy5")

    suite = []
    append_T(suite, T)
    yaml.dump(suite, sys.stdout)

def append_T(suite, T):
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"
    priv_spec_mit="configs/priv-spec-mit.defconfig"

    # All programs:
    for prog_path in Path("../system/bpf-samples/.build/").glob("*.bpf.o"):
        prog = Path(Path(prog_path.name).stem).stem # basename, without .bpf.o

        if "custom_varstackw" not in prog:
            continue

        # Skip priv_spec_mit with unpriv user because it will be the same as
        # regular unpriv.
        for (ca, sc) in [(unpr, "")]:
            suite.append({
                "bench_script": "bpftool",
                "boot": {},
                "run": {
                    "T": T,
                    "CPUFREQ": "base",
                    "CAPSH_ARGS": ca,
                    "SYSCTL": sc,
                    "BPF_OBJ": prog + ".bpf.o",
                    "MERGE_CONFIGS": "",
                },
            })

if __name__ == "__main__":
    main()