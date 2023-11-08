#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
set -x

# Arguments from suite runner:
dst=$(realpath "$1")
burst_len=$2

set +x
env_exports="$(export -p | grep OSE_)"
set -x

pushd ../src

# Also sets default SuT ($T) and related variables.
. ./env.sh

# Boots target with linux-build ready for target-scpsh.
make -j "$(nproc)" target

set +x
./scripts/target-scpsh -o ${dst}/.tmp -C ./target-scripts "
${env_exports}
./bench-loxilb.sh ../result_dir ${burst_len}
"
set -x

mv --no-clobber --target-directory=${dst} ${dst}/.tmp/*
rm -d ${dst}/.tmp
