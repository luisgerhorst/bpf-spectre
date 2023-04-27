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

    # bcc upstream -= javagc
    bcc_apps = ["memleak", "opensnoop", "bashreadline", "bindsnoop",
                "biolatency", "biopattern",
                #
                # BUG: prog does not load
                # "biosnoop",
                "biostacks", "biotop", "bitesize",
                "cachestat", "capable", "cpudist",
                #
                # in kvm: failed to open '/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq': No such file or directory
                "cpufreq",
                "drsnoop", "execsnoop",
                "exitsnoop", "filelife",
                #
                # Needs file?:
                # "filetop",
                #
                # Filesystem must be specified with -t:
                "fsdist -t ext4",
                "fsslower -t ext4",
                #
                # Needs function to trace:
                "funclatency do_sys_open",
                "funclatency -m do_nanosleep",
                "funclatency -u vfs_read",
                "gethostlatency", "hardirqs", "klockstat",
	            "ksnoop info ip_send_skb",
                "llcstat",
                #
                # TODO: for this, enable more perf cpu events?
                "mdflush",
                "mountsnoop", "numamove", "offcputime", "oomkill",
                # TODO: kvm: failed to set attach target for do_page_cache_ra: No such process
                "readahead",
                "runqlat",
                "runqlen", "runqslower", "sigsnoop",
                "slabratetop --noclear",
                "softirqs", "solisten",
                "statsnoop", "syscount", "tcptracer", "tcpconnect", "tcpconnlat",
                "tcplife",
                "tcprtt", "tcpstates", "tcpsynbl", "tcptop", "vfsstat", "wakeuptime"]

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
        # The default 4 threads x 50 clients x 10k requests takes 13s.
        mb = "/usr/bin/memtier_benchmark --port=11211 --protocol=memcache_binary"

        # pts uses --hide-histogram --protocol=memcache_text --pipeline=16 --threads=$(nproc) --clients=1 --test-time=60.
        mb = "/usr/bin/memtier_benchmark --hide-histogram --protocol=memcache_text --port=$RANDOM_PORT --pipeline=16 --threads=$(nproc) --clients=1 --requests=5000000 --ratio=1:5"

        bamb = []
        for ba in bcc_apps:
           bamb += ["sudo ./sigint-wrap.sh --siw-trace " + ba + " --siw-command " + mb]

        for w in [
                "sudo " + mb,
                "sudo trace " + mb
                # "sudo ./bpftrace-syscount-comm.sh " + mb
        ] + bamb:
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
                    # pts uses --conn-limit=4096 --threads=$(nproc)
                    "WORKLOAD_PREPARE": "memcached --port=$RANDOM_PORT --conn-limit=4096 --threads=$(nproc) & echo $! > memcached_pid",
                    "WORKLOAD": w,
                    "WORKLOAD_CLEANUP": "kill $(cat memcached_pid)",
                },
            })

if __name__ == "__main__":
    main()
