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

    # T = os.getenv("BENCHRUN_DEFAULT_SUT", default="faui49easy6")

    suite = []
    # for T in ["faui49easy6", "faui49man1"]:
    #     append_T(suite, T)
    append_T(suite, "faui49easy6")
    yaml.dump(suite, sys.stdout)

def append_T(suite, T):
    priv="--drop="
    unpriv="--drop=cap_sys_admin --drop=cap_perfmon"
    priv_spec_mit="configs/priv-spec-mit.defconfig"

    # All programs:
    for prog_path in Path("../system/bpf-samples/prog").iterdir():
        prog = Path(Path(prog_path.name).stem).stem # basename, without .bpf.s
        # Skip priv_spec_mit with unpriv user because it will be the same as
        # regular unpriv.
        for (mcs, ca, bjh) in [("", unpriv, "1"), ("", unpriv, "0"),
                               (priv_spec_mit, priv, "0"),
                               ("", priv, "1"), ("", priv, "0")]:
            suite.append({
                "bench_script": "bpftool",
                "boot": {
                    "MERGE_CONFIGS": mcs
                },
                "run": {
                    "T": T,
                    "CPUFREQ": "base",
                    "CAPSH_ARGS": ca,
                    "BPF_JIT_HARDEN": bjh,
                    "BPF_OBJ": prog + ".bpf.o",
                },
            })

if __name__ == "__main__":
    main()
