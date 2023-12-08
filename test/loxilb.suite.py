#!/usr/bin/env python3

import sys
import logging
import math

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"
    configs = [
        (priv, "kernel.bpf_stats_enabled=1 net.core.bpf_jit_harden=0", "HEAD-dirty"),
        (priv, "kernel.bpf_stats_enabled=1 kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=2", "HEAD-dirty"),

        # TODO: fix loxilb?: ERR:  2023/11/23 17:17:28 ebpf load - 3 error
        # (priv, "kernel.bpf_stats_enabled=1 kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=0", "HEAD-dirty"),
        # (priv, "kernel.bpf_stats_enabled=1 kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
    ]
    nproc = 6
    nproc_servers = 2 # 1 loxilb, 1 server
    nproc_clients = nproc - nproc_servers
    workloads = [
        ("netperf", 1, "TCP_RR"),
        ("netperf", nproc_clients, "TCP_RR"),
        ("netperf", 1, "TCP_CRR"),
        ("netperf", nproc_clients, "TCP_CRR"),
        ("iperf", 1),
        ("iperf", nproc_clients),
        ("iperf3-tcp", 1),
        ("iperf3-sctp", 1),
    ]

    for T in ["faui49easy4"]:
        for vp in workloads:
            v = "NA"
            p = "NA"
            t = "NA"
            if len(vp) == 2:
                v, p = vp
            else:
                v, p, t = vp
            for (_ca, sc, b) in configs:
                suite.append({
                    "bench_script": "loxilb",
                    "boot": {
                        "LINUX_GIT_CHECKOUT": b,
                    },
                    "run": {
                        "T": T,
                        "OSE_CPUFREQ": "base",
                        "OSE_SYSCTL": sc,
                        "OSE_LOXILB_VALIDATION": v,
                        "OSE_LOXILB_CLIENTS": str(p),
                        "OSE_LOXILB_SERVERS": str(1),
                        "OSE_LATENCY_PAYLOAD_SIZE": str(1024),
                        "OSE_NETPERF_TEST": t
                    },
                })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
