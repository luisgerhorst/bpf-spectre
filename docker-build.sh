#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
shopt -s nullglob
set -x

docker build -t $(basename $(pwd)) \
    --build-arg USER=$USER --build-arg UID=$(id -u $USER) .
