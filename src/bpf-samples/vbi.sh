#!/usr/bin/env bash
set -euo pipefail
set -x

rm -f .build/vbi-*_*.bpf.o prog/vbi_*.bpf.o .build/vbi_*.bpf.o
for o in external/vbpf/*/*.o
do
    if [ $(basename $(dirname $o)) = "build" ]
    then
        continue
    fi
    ln -s ../$o .build/vbi-$(basename $(dirname $o) | sed s/_/-/g)_$(basename --suffix=.o $o).bpf.o
done
