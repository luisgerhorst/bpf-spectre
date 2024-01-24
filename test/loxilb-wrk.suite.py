#!/usr/bin/env python3

import sys
import logging
import math
import os

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []
    priv="--drop="
    unpr="--drop=cap_sys_admin --drop=cap_perfmon"
    configs = [
        (priv, "net.core.bpf_jit_harden=0", "HEAD-dirty"),
        # (priv, "kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=2", "HEAD-dirty"),
        # (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=0", "HEAD-dirty"),
        (priv, "kernel.bpf_spec_v1=2 kernel.bpf_spec_v4=2", "HEAD-dirty"),
    ]

    workloads = [
        # ("wrk", 1),
        ("wrk", 2),
        # ("wrk", 3),
        # ("wrk", 4),
        # ("wrk", 5),
        # ("wrk", 6),
    ]
    for T in [os.getenv("T", default="faui49easy2")]:
        for v, p in workloads:
            # Each nginx can handle up to ~16k RPS.
            for rpn in [12500, 14000, 15500]:
                # https://nginx.org/en/docs/ngx_core_module.html#worker_connections
                r = p * rpn
                # For connections per server, out of [1, 256, 1024] for 2
                # clients/servers, 256 lead to the most clear diff. in bpf
                # runtime. 1 was also fine but did not hit the target rate. (but
                # with smaller diffs). 1024 hindered reproducibility.
                for wef in [""]:
                    c = p * 256
                    # With 64k payload, we can not reach 14k RPS per nginx
                    # worker. With 4k payload, the diff between
                    # mitigated/unmitigated is even smaller. 1B payload behaves
                    # alsmost exactly like 1kB payload.
                    for payload in [1024]:
                        for (_ca, sc, b) in configs:
                            suite.append({
                                "bench_script": "loxilb-burst",
                                "boot": {
                                    "LINUX_GIT_CHECKOUT": b,
                                },
                                "run": {
                                    "T": T,
                                    "OSE_CPUFREQ": "base",
                                    "OSE_SYSCTL": "kernel.bpf_stats_enabled=1 kernel.bpf_complexity_limit_jmp_seq=16384 kernel.bpf_spec_v1_complexity_limit_jmp_seq=8192 " + sc,
                                    "OSE_LOXILB_VALIDATION": v,
                                    "OSE_LOXILB_SERVERS": str(p),
                                    "OSE_LOXILB_CLIENTS": str(p),
                                    "OSE_LOXILB_TIME": str(60),
                                    "OSE_LATENCY_PAYLOAD_SIZE": str(payload),
                                    "OSE_WRK_CONNECTIONS": str(c),
                                    "OSE_WRK_RATE": str(r),
                                    "OSE_WRK_EXTRA_FLAGS": wef,
                                    "OSE_PERF_EVENTS": "-e power/energy-cores/ -e power/energy-pkg/ -e power/energy-ram/",
                                },
                            })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
