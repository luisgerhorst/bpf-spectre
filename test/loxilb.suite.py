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
    workloads = [
        ("netperf", 1, "TCP_RR"),
        ("netperf", 6, "TCP_RR"),
        ("netperf", 60, "TCP_RR"),
        ("netperf", 1, "TCP_CRR"),
        ("netperf", 6, "TCP_CRR"),
        ("netperf", 60, "TCP_CRR"),
        ("iperf", 1),
        ("iperf", 6),
        ("iperf", 60),
        ("iperf3-tcp", 1),
        ("iperf3-tcp", 6),
        ("iperf3-tcp", 60),
        ("iperf3-sctp", 1),
        ("iperf3-sctp", 6),
        ("iperf3-sctp", 60),
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
                        "OSE_LOXILB_PARALLEL": str(p),
                        "OSE_NETPERF_TEST": t
                    },
                })

    workloads = [
        ("wrk", 1),
        ("wrk", 3),
    ]
    for T in ["faui49easy4"]:
        for v, p in workloads:
            for rf in [1000, 5000, 10000]:
                r = p * rf
                # https://nginx.org/en/docs/ngx_core_module.html#worker_connections
                for cf in [256]:
                    c = p * cf
                    for payload in [8, 1024, 64*1024]:
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
                                    "OSE_LOXILB_PARALLEL": str(p),
                                    "OSE_NGINX_PAYLOAD": str(payload),
                                    "OSE_WRK_CONNECTIONS": str(c),
                                    "OSE_WRK_RATE": str(r),
                                },
                            })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
