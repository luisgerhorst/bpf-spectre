#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
shopt -s nullglob
set -x

. ./env.sh

mkdir -p .build/env
env -0 | while IFS='=' read -r -d '' n v; do
    if [ ! -e .build/env/$n ] || [ "$(cat .build/env/$n)" != "$v" ]
    then
        echo -n "$v" > .build/env/$n
    fi
done

LINUX=${LINUX:-linux}
LINUX_MAIN=${LINUX_MAIN:-linux-main}
MAKE=${MAKE:-make}

checkout=$LINUX_GIT_CHECKOUT
lco=linux-main
if test $checkout != HEAD-dirty
then
    # Same directory because of make deb-pkg.
    lco=.linux.$checkout
    if ! test -e $lco/.git
    then
        env -C $LINUX_MAIN git worktree add --force ../$lco origin/$checkout
    fi

    old_rev=$(env -C $l git rev-parse HEAD || echo null)
    env -C $l git fetch
    env -C $l git checkout origin/$checkout
    new_rev=$(env -C $l git rev-parse HEAD)
    if [ $old_rev != $new_rev ]
    then
        # To prevent missing headers when making libbbpf. Also, generated config is
        # invalid after source change.
        $MAKE -C $l mrproper
    fi
fi
ln --no-target-directory -sf $lco $LINUX

for linux in ${LINUX} ${LINUX_MAIN}
do
    ./scripts/update-git-rev $linux .build/$linux.git_rev
    ./scripts/update-git-status $linux .build/$linux.git_status
    ${MAKE} -f release.mk LINUX=$linux $linux/.config
    test "$MERGE_CONFIGS" != "" \
        || diff $CONFIG $linux/defconfig
done
