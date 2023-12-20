#!/usr/bin/env bash
{
    set -euo pipefail
    bash -n "$(command -v "$0")"

    set -x

    # Arguments from suite runner:
    dst=$(realpath $1)
    burst_len=$2

    env_exports="$(export -p | grep OSE_)"

    pushd ../src

    # Also sets default SuT ($T) and related variables.
    . ./env.sh

    # Boots target with linux-build ready for target-scpsh.
    make -j $(expr $(nproc) '+' 1) target

    cp -f bpf-samples/.build/$OSE_BPF_OBJ $dst/$OSE_BPF_OBJ

    tempd=$(mktemp -d)
    cp -r target-scripts $tempd/dir
    cp bpf-samples/.build/$OSE_BPF_OBJ $tempd/dir/$OSE_BPF_OBJ
    ./scripts/target-scpsh -o ${dst}/.tmp-$(basename $0) -C $tempd/dir "
${env_exports}
./bench-bpftool.sh ../result_dir ${burst_len}
"
    rm -rfd $tempd

    mv --no-clobber --target-directory=${dst} ${dst}/.tmp-$(basename $0)/*
    rm -d ${dst}/.tmp-$(basename $0)

    env -C linux git log --pretty=format:"%h (\"%s\")" -1 > ${dst}/values/linux_git_rev_h
    env -C linux git log --pretty=format:"%h" -1 > ${dst}/values/linux_git_rev

    exit
}
