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

    # bcc upstream:
    bcc_apps = [
        # BUG: prog does not load
        # "biosnoop",
        # BUG: libbpf: prog 'blk_account_io_done': failed to find kernel BTF type ID of 'blk_account_io_done': -3
        # "biostacks",
        # Needs file:
        # "filetop",
        # Not useful:
        # "javagc"
        # BUG: failed to resolve CO-RE relocation <byte_off> [81] struct trace_event_raw_kmem_alloc.bytes_alloc (0:4 @ offset 32)
        # "memleak",
        # BUG: 'unknown': I need something more specific.
        # "tcptop",
        # BUG: failed to set attach target for do_page_cache_ra: No such process
        # "readahead",
        # BUG: ??
        "vfsstat",
        #
        "opensnoop", "bashreadline", "bindsnoop",
        "biolatency", "biopattern",
        "biotop", "bitesize",
        "cachestat", "capable",
        "cpudist",
        "cpufreq", # in kvm: failed to open '/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq': No such file or directory
        "drsnoop", "execsnoop",
        "exitsnoop", "filelife",
        "fsdist -t ext4", # Filesystem must be specified with -t.
        "fsslower -t ext4",
        "funclatency do_sys_open", # Needs function to trace
        "funclatency -m do_nanosleep",
        "funclatency -u vfs_read",
        "gethostlatency", "hardirqs",
        "klockstat",
        "ksnoop info ip_send_skb",
        "llcstat",
        "mdflush", # TODO: for this, enable more perf cpu events?
        "mountsnoop", "numamove", "offcputime", "oomkill",
        "runqlat",
        "runqlen",
        "runqslower",
        "sigsnoop",
        "slabratetop --noclear",
        "softirqs",
        "solisten",
        "statsnoop", "syscount", "tcptracer", "tcpconnect", "tcpconnlat",
        "tcplife",
        "tcprtt", "tcpstates", "tcpsynbl",
        "wakeuptime"
    ]

    bcc_apps = [
        "true",

        # >0 runs for memtier_benchmark/memcached:
        # "tcprtt",
        # "syscount",
        # "softirqs",
        # "slabratetop --noclear",
        # "runqslower",
        # "runqlat",
        # "offcputime",
        # "klockstat",
        # "funclatency -u vfs_read",
        # "cpudist",
    ]

    bcc_apps += [
        # BUG: level=error name=parca-agent ts=2024-01-30T18:47:24.131490014Z caller=main.go:512 err="load bpf program: failed to load BPF object: argument list too long"
        "parca-agent --analytics-opt-out --bpf-verbose-logging --local-store-directory=.",
        # "parca-agent --analytics-opt-out --bpf-verbose-logging --profiling-cpu-sampling-frequency=997",
    ]

    # Skip priv_spec_mit with unpriv user because it will be the same as
    # regular unpriv.
    sc_d = "kernel.bpf_stats_enabled=1"
    for (_ca, sc, b) in [
            (priv, "net.core.bpf_jit_harden=0", "bpf-spectre-baseline"), # Baseline (Very Unsafe)
            # (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "bpf-spectre-baseline"), # Safe Baseline (only used for unpriv.)
            (priv, "kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=2", "HEAD-dirty"), # Baseline (Unsafe)
            (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
    ]:
        sc = sc_d + " " + sc

        # The default 4 threads x 50 clients x 10k requests takes 13s.
        # mb = "/usr/bin/memtier_benchmark --port=$OSE_RANDOM_PORT --protocol=memcache_binary"
        #
        # pts uses --hide-histogram --protocol=memcache_text --pipeline=16 --threads=$(nproc) --clients=1 --test-time=60.
        # mb = "/usr/bin/memtier_benchmark --hide-histogram --protocol=memcache_text --port=$OSE_RANDOM_PORT --pipeline=16 --threads=$(nproc) --clients=1 --requests=5000000 --ratio=1:5"
        #
        # Mix of pts and default, nproc/2 to reduce jitter:
        mb = "memtier_benchmark --port=$OSE_RANDOM_PORT --protocol=memcache_binary --threads=$(expr $(nproc) '/' 2)"

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
