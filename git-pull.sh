#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
shopt -s nullglob
set -x

MAKE=${MAKE:-make}

git pull --recurse-submodules

for dir in src/.linux.*
do
    l=$(basename $dir)
    checkout=$(echo $l | cut --delimiter=. --fields=3)

    env -C $dir git fetch

    old_rev=$(env -C $dir git rev-parse HEAD || echo null)
    env -C $dir git checkout origin/$checkout
    new_rev=$(env -C $dir git rev-parse HEAD)
    if [ $old_rev != $new_rev ]
    then
        # To prevent missing headers when making libbbpf. Also, generated config is
        # invalid after source change.
        $MAKE -C $dir mrproper
    fi
done
