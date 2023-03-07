#!/usr/bin/env bash
set -euo pipefail
set -x

LINUX=${LINUX:-linux}

current_branch=$(env -C $LINUX git rev-parse --abbrev-ref HEAD)
checkout=${LINUX_GIT_CHECKOUT:-${current_branch}}
if [ "$checkout" != "$current_branch" && "$checkout" != HEAD ]
then
    # TODO: git stash, and unstash on new branch
    env -C "$LINUX" git checkout $checkout
fi
