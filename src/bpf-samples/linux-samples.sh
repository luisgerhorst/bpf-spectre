#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
set -x

lsb=../linux/samples/bpf

rm -f .build/linux-samples_*.bpf.o

for o in ${lsb}/*.bpf.o
do
    name=$(basename --suffix=.bpf.o $o)
    ln -fs ../$o .build/linux-samples_$name.bpf.o
done

for o in ${lsb}/*_kern.o
do
    name=$(basename --suffix=.o $o)
    ln -fs ../$o .build/linux-samples_$name.bpf.o
done
