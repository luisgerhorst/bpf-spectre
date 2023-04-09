#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
set -x

project=$1
dir=$2

for o in $dir/*.bpf.o
do
    n=$(basename --suffix=.bpf.o $o)
    ln -fs ../$o .build/${project}_${n}.bpf.o
done
