#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
set -x

linux=../linux-main
bpf=$linux/tools/testing/selftests/bpf

# -maxdepth 1: exclude no_alu32
list=$(find -L "${bpf}/" -name '*.bpf.o' -not -path '**/bpf/no_alu32/*.bpf.o' | sort --stable)
if ! test -e linux-selftests.list
then
   echo "$list" > linux-selftests.list
else
   echo "$list" > .build/linux-selftests.list
   diff -u linux-selftests.list .build/linux-selftests.list || true
fi

IFS=$'\n'
for o in $(cat linux-selftests.list)
do
    name=$(basename --suffix=.bpf.o $o)
    ln -fs ../$o .build/linux-selftests_$name.bpf.o
done
unset IFS
