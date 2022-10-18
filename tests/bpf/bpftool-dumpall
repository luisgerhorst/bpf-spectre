#!/bin/bash
set -euo pipefail
path="$1"
for prog in $path/*
do
    bpftool prog dump xlated pinned "$prog"
done
