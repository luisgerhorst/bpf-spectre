#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
shopt -s nullglob
set -x

. ./env.sh

mkdir -p .build/env
set +x
env -0 | while IFS='=' read -r -d '' n v; do
    if [ ! -e .build/env/$n ] || [ "$(cat .build/env/$n)" != "$v" ]
    then
        echo -n "$v" > .build/env/$n
    fi
done
set -x

LINUX=${LINUX:-linux}
LINUX_MAIN=${LINUX_MAIN:-linux-main}
MAKE=${MAKE:-make}

checkout=$LINUX_GIT_CHECKOUT
l=linux-main
if test $checkout != HEAD-dirty
then
    # Same directory because of make deb-pkg.
    l=.linux.$checkout

    if ! test -e $l/.git
    then
        env -C $LINUX_MAIN git worktree add --force ../$l $checkout
        env -C $l git checkout --detach HEAD # prevent worktree checkout conflicts
    fi
fi
ln --no-target-directory -sf $l $LINUX

for linux in ${LINUX} ${LINUX_MAIN}
do
    ./scripts/update-git-rev $linux .build/$linux.git_rev
    ./scripts/update-git-status $linux .build/$linux.git_status
    ${MAKE} -f release.mk LINUX=$linux $linux/.config
    test "$MERGE_CONFIGS" != "" \
        || diff $CONFIG $linux/defconfig \
        || true
done
