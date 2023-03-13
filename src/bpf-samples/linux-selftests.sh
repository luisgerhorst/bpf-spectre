#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
set -x

linux=../linux-main
bpf=$linux/tools/testing/selftests/bpf

# -maxdepth 1: exclude no_alu32
list=$(find "${bpf}/" -name '*.bpf.o' -not -path '**/bpf/no_alu32/*.bpf.o' | sort)
if ! test -e linux-selftests.list
then
   echo "$list" >  linux-selftests.list
fi
test "$list" = "$(cat linux-selftests.list)"

IFS=$'\n'
for o in $list
do
    name=$(basename --suffix=.bpf.o $o)
    ln -fs ../$o .build/linux-selftests_$name.bpf.o
done
unset IFS
