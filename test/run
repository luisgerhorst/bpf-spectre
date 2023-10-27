#!/usr/bin/env bash
set -euo pipefail
set -x

DIR=$(dirname "$(command -v $0)")
time nice env -C ${DIR} ./run.py "$@"
