#!/usr/bin/env bash
{
    set -euo pipefail
    bash -n "$(command -v "$0")"

    set -x

    # Arguments from suite runner:
    dst=$(realpath $1)
    burst_len=$2

    # TODO: Maybe it's not a good idea to send the whole env to the target. Use
    # make-style var=value args instead.
    set +x
    env_exports="$(export -p)"

    pushd ../src

    # Also sets default SuT ($T) and related variables.
    . ./env.sh

    # Boots target with linux-build ready for target-scpsh.
    make -j $(nproc) target

    cp -f bpf-samples/.build/$BPF_OBJ $dst/$BPF_OBJ

    tempd=$(mktemp -d)
    cp -r target-scripts $tempd/dir
    cp bpf-samples/.build/$BPF_OBJ $tempd/dir/$BPF_OBJ
    ./scripts/target-scpsh -o ${dst}/.tmp-$(basename $0) -C $tempd/dir "
${env_exports}
./bench-bpftool.sh ../result_dir ${burst_len}
"
    set -x
    rm -rfd $tempd

    mv --no-clobber --target-directory=${dst} ${dst}/.tmp-$(basename $0)/*
    rm -d ${dst}/.tmp-$(basename $0)

    env -C linux git log --pretty=format:"%h (\"%s\")" -1 > ${dst}/values/linux_git_rev_h
    env -C linux git log --pretty=format:"%h" -1 > ${dst}/values/linux_git_rev

    exit
}
