#!/usr/bin/env bash
set -euo pipefail
set -x

linux=../linux
bpf=$linux/tools/testing/selftests/bpf

for o in ${bpf}/*.bpf.o
do
    name=$(basename --suffix=.bpf.o $o)
    ln -fs ../$o .build/linux-selftests_$name.bpf.o
done

if cat .build/make-linux-selftests.stderr | \
    grep --extended-regexp "^make: .+ Error [0-9]+$" | \
    grep --invert-match "find_vma_fail1.bpf.o"
then
    exit 1
fi
