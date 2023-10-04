#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
shopt -s nullglob
set -x

docker run --tty --interactive --volume $HOME:$HOME \
    $(basename $(pwd)) /usr/bin/zsh
