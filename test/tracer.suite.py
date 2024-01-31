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

    T = os.getenv("T", default="faui49easy4")

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
                #
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
                "gethostlatency", "hardirqs",
                "klockstat",
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
                "tcprtt", "tcpstates", "tcpsynbl", "tcptop",
                "vfsstat",
                "wakeuptime"]

    # Only these are interesting:
    # bcc_apps = ["klockstat", "wakeuptime", "tcprtt", "offcputime"]

    bcc_apps += [
        "parca-agent",
        "parca-agent --profiling-cpu-sampling-frequency=997",
    ]

    # Skip priv_spec_mit with unpriv user because it will be the same as
    # regular unpriv.
    sc_d = "kernel.bpf_stats_enabled=1"
    for (_ca, sc, b) in [
            # (unpr, "net.core.bpf_jit_harden=0", "master"),
            # (priv, "net.core.bpf_jit_harden=0", "master"),
            # (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "bpf-spectre"),
            # (priv, "kernel.bpf_spec_v1=2", "bpf-spectre"),
            # (priv, "kernel.bpf_spec_v1=2", "bpf-spectre-v1-nospec~1"),
            # (priv, "kernel.bpf_spec_v1=2", "bpf-spectre-v1-nospec"),
            # (priv, "kernel.bpf_spec_v1=2", "HEAD"),
            (priv, "net.core.bpf_jit_harden=0", "HEAD-dirty"),
            # (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=0", "HEAD-dirty"),
            # (priv, "kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=2", "HEAD-dirty"),
            (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
            # (priv, "kernel.bpf_spec_v4=2"),
            # (priv, "net.core.bpf_jit_harden=2"),
    ]:
        sc = sc_d + " " + sc

        # The default 4 threads x 50 clients x 10k requests takes 13s.
        # mb = "/usr/bin/memtier_benchmark --port=$OSE_RANDOM_PORT --protocol=memcache_binary"
        #
        # pts uses --hide-histogram --protocol=memcache_text --pipeline=16 --threads=$(nproc) --clients=1 --test-time=60.
        # mb = "/usr/bin/memtier_benchmark --hide-histogram --protocol=memcache_text --port=$OSE_RANDOM_PORT --pipeline=16 --threads=$(nproc) --clients=1 --requests=5000000 --ratio=1:5"
        #
        # Mix of pts and default, nproc/2 to reduce jitter:
        mb = "/usr/bin/memtier_benchmark --port=$OSE_RANDOM_PORT --protocol=memcache_binary --threads=$(expr $(nproc) '/' 2)"

        for ba in bcc_apps:
            suite.append({
                "bench_script": "tracer",
                "boot": {
                    "LINUX_GIT_CHECKOUT": b,
                },
                "run": {
                    "T": T,
                    "MERGE_CONFIGS": "",
                    "OSE_CPUFREQ": "base",
                    "OSE_SYSCTL": sc,
                    "OSE_CAPSH_ARGS": "NA",
                    # pts uses --conn-limit=4096 --threads=$(nproc)
                    "OSE_WORKLOAD_PREPARE": "memcached --port=$OSE_RANDOM_PORT --conn-limit=4096 --threads=$(expr $(nproc) '/' 2) & echo $! > memcached_pid",
                    "OSE_TRACER": "sudo " + ba,
                    "OSE_WORKLOAD": mb,
                    "OSE_WORKLOAD_CLEANUP": "kill $(cat memcached_pid)",
                },
            })

if __name__ == "__main__":
    main()
