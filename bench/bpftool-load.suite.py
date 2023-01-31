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

    suite = []

    T = os.getenv("BENCHRUN_DEFAULT_SUT", default="faui49easy6")

    priv="--drop="
    unpriv="--drop=cap_sys_admin --drop=cap_perfmon"

    priv_spec_mit="configs/priv-spec-mit.defconfig"

    # TODO: Also test with/without /proc/sys/net/core/bpf_jit_harden set.

    subprocess.run(["make", "-C", "../system/bpf-samples"], check=True,
                   stdout=sys.stderr.buffer)

    # All programs:
    for prog_path in Path("../system/bpf-samples/prog").iterdir():
        prog = Path(Path(prog_path.name).stem).stem # basename, without .bpf.s
        # Skip priv_spec_mit with unpriv user because it will be the same as
        # regular unpriv.
        for (mcs, ca) in [("", unpriv), (priv_spec_mit, priv), ("", priv)]:
            suite.append({
                "bench_script": "bpftool",
                "boot": {
                    "MERGE_CONFIGS": mcs
                },
                "run": {
                    "T": T,
                    "CPUFREQ": "max",
                    "CAPSH_ARGS": ca,
                    "BPF_OBJ": prog + ".bpf.o",
                },
            })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
