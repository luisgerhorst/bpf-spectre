#!/usr/bin/env bash
set -euo pipefail
set -x

LINUX=${LINUX:-linux}
LINUX_MAIN=${LINUX_MAIN:-linux-main}
MAKE=${MAKE:-make}
MERGE_CONFIGS=${MERGE_CONFIGS:-}

checkout=${LINUX_GIT_CHECKOUT:-HEAD}
# Same directory because of make deb-pkg.
lco=.linux.$checkout
old_rev=$(env -C $lco git rev-parse HEAD || echo null)
env -C $LINUX_MAIN git worktree add --force ../$lco $checkout || true
env -C $lco git checkout --force --detach $checkout
new_rev=$(env -C $lco git rev-parse HEAD)
if [ $old_rev != $new_rev ]
then
    # To prevent missing headers when making libbbpf. Also, generated config is
    # invalid after source change.
    $MAKE -C $lco mrproper
fi
ln --no-target-directory -sf $lco $LINUX

for linux in ${LINUX} ${LINUX_MAIN}
do
    ./scripts/update-git-rev $linux .build/$linux.git_rev
    ./scripts/update-git-status $linux .build/$linux.git_status
    ${MAKE} -f release.mk LINUX=$linux $linux/.config
done
