#!/usr/bin/env bash
set -euo pipefail
set -x

LINUX=${LINUX:-linux}
LINUX_MAIN=${LINUX_MAIN:-linux-main}
MAKE=${MAKE:-make}
MERGE_CONFIGS=${MERGE_CONFIGS:-}

old_rev=$(env -C $LINUX git rev-parse HEAD || echo null)
pushd $LINUX_MAIN
current_main_branch=$(git rev-parse --abbrev-ref HEAD)
commit_ish=${LINUX_GIT_CHECKOUT:-${current_main_branch}}
git worktree add --force ../${LINUX} $commit_ish \
    || env -C ../${LINUX} git checkout --force --detach $commit_ish
popd
new_rev=$(env -C $LINUX git rev-parse HEAD)
if [ $old_rev != $new_rev ]
then
    # To prevent missing headers when making libbbpf. Also, generated config is
    # invalid after source change.
    $MAKE -C $LINUX mrproper
fi

for linux in ${LINUX} ${LINUX_MAIN}
do
    ./scripts/update-git-rev $linux .build/$linux.git_rev
    ./scripts/update-git-status $linux .build/$linux.git_status
    # TODO: localmodconfig for i4lab
    ${MAKE} -f release.mk LINUX=$linux $linux/.config
done
