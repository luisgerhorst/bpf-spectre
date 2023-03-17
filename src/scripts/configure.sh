#!/usr/bin/env bash
set -euo pipefail
set -x

. ./env.sh

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
        env -C $LINUX_MAIN git worktree add --force ../$lco $checkout
    fi

    # TODO: Move this into separate top-level git-pull script?
    old_rev=$(env -C $lco git rev-parse HEAD || echo null)
    env -C $lco git fetch
    env -C $lco git checkout origin/$checkout
    new_rev=$(env -C $lco git rev-parse HEAD)
    if [ $old_rev != $new_rev ]
    then
        # To prevent missing headers when making libbbpf. Also, generated config is
        # invalid after source change.
        $MAKE -C $lco mrproper
    fi
fi
ln --no-target-directory -sf $lco $LINUX

mkdir -p .build/env
env -0 | while IFS='=' read -r -d '' n v; do
    if [ ! -e .build/env/$n ] || [ "$(cat .build/env/$n)" != "$v" ]
    then
        echo -n "$v" > .build/env/$n
    fi
done

for linux in ${LINUX} ${LINUX_MAIN}
do
    ./scripts/update-git-rev $linux .build/$linux.git_rev
    ./scripts/update-git-status $linux .build/$linux.git_status
    ${MAKE} -f release.mk LINUX=$linux $linux/.config
    diff $CONFIG $linux/defconfig # sanity check, BUG: no merge configs support
done
