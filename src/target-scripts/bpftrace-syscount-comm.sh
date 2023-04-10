#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"

c="$@"

bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }' -c "$c"
