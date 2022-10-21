#!/bin/bash
set -uo pipefail
set -x

obj="$1"

uname -a
pwd

path=/sys/fs/bpf/$(basename $obj .bpf.o)
bpftool prog loadall $obj $path 2> ../result_dir/loadall.log
echo $? > ../result_dir/loadall.exitcode

shopt -s nullglob
for prog in "$path"/*
do
    bpftool prog dump xlated pinned "$prog" > ../result_dir/xlated.$(basename $prog)
    bpftool prog dump jited pinned "$prog" > ../result_dir/jited.$(basename $prog)
done

rm -rfd $path
