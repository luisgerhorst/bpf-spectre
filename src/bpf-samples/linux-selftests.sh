#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
set -x

linux=../linux-main
bpf=$linux/tools/testing/selftests/bpf

# -maxdepth 1: exclude no_alu32
list=$(find -L "${bpf}/" -name '*.bpf.o' \
    -not -path '**/bpf/no_alu32/*.bpf.o' \
    -not -path '**/bpf/bpf_gcc/*.bpf.o' \
    | sort --stable)
if ! test -e linux-selftests.list
then
   echo "$list" > linux-selftests.list
fi

IFS=$'\n'
for o in $(cat linux-selftests.list)
do
    name=$(basename --suffix=.bpf.o $o)
    p=.build/linux-selftests_$name.bpf.o
    if ! test -e $o
    then
       echo "$list" > linux-selftests.list.new
       diff -u linux-selftests.list linux-selftests.list.new
       exit 1
    fi
    ln -fs ../$o $p
done
unset IFS
