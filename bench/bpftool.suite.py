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

    # TODO: Read default from environment.
    T="faui49easy6"

    priv="--drop="
    unpriv="--drop=cap_sys_admin --drop=cap_perfmon"

    priv_spec_mit="configs/priv-spec-mit.defconfig"

    # TODO: Also test with/without /proc/sys/net/core/bpf_jit_harden set.

    subprocess.run(["make", "-C", "../system/bpf-samples"], check=True,
                   stdout=sys.stderr.buffer)

    # All programs:
    # for prog_path in Path("../system/bpf-samples/prog").iterdir():
        # prog = Path(Path(prog_path.name).stem).stem # basename, without .bpf.s

    # Programs runnable with empty input:
    for prog in ["vbpf_write_read_stack_slot", "vbpf_loop_init_stack_slot"]:
        # Skip priv_spec_mit with unpriv user because it will be the same as
        # regular unpriv.
        for (mcs, ca) in [(priv_spec_mit, priv), ("", priv)]:
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
