#!/usr/bin/env bash
set -euo pipefail
set -x

DIR=$(dirname "$(command -v $0)")
nice env -C ${DIR} ./run.py "$@"
