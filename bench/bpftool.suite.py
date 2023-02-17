#!/usr/bin/env python3

import sys
import logging
import math
import os
import subprocess
from pathlib import Path

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    subprocess.run(["make", "-C", "../system/bpf-samples", "clean", "all"],
                   check=True, stdout=sys.stderr.buffer)

    T = os.getenv("T", default="faui49easy6")

    suite = []
    # for T in ["faui49easy6", "faui49man1"]:
    #     append_T(suite, T)
    append_T(suite, T)
    yaml.dump(suite, sys.stdout)

def append_T(suite, T):
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"
    priv_spec_mit="configs/priv-spec-mit.defconfig"

    # All programs:
    for prog_path in Path("../system/bpf-samples/.build/").glob("*.bpf.o"):
        prog = Path(Path(prog_path.name).stem).stem # basename, without .bpf.o

        if "katran" not in prog:
            continue

        # Skip priv_spec_mit with unpriv user because it will be the same as
        # regular unpriv.
        for (ca, sc) in [(unpr, ""),
                         (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2"),
                         (priv, "kernel.bpf_spec_v1=2"),
                         (priv, "kernel.bpf_spec_v4=2"),
                         (priv, "net.core.bpf_jit_harden=2"),
                         (priv, "net.core.bpf_jit_harden=0")]:
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
