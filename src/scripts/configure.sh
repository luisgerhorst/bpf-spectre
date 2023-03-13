#!/usr/bin/env bash
set -euo pipefail
set -x

LINUX=${LINUX:-linux}
LINUX_MAIN=${LINUX_MAIN:-linux-main}
MAKE=${MAKE:-make}
MERGE_CONFIGS=${MERGE_CONFIGS:-}

pushd $LINUX_MAIN
current_branch=$(git rev-parse --abbrev-ref HEAD)
commit_ish=${LINUX_GIT_CHECKOUT:-${current_branch}}
git worktree add --force ../${LINUX} $commit_ish \
    || env -C ../${LINUX} git checkout --force --detach $commit_ish
popd

# TODO: auto gen .build/env/$VAR
if [ ! -e .build/merge_configs_value ] \
    || [ "$(cat .build/merge_configs_value)" != "${MERGE_CONFIGS}" ]
then
    echo -n "${MERGE_CONFIGS}" > .build/merge_configs_value
fi

for linux in ${LINUX} ${LINUX_MAIN}
do
    ./scripts/update-git-rev $linux .build/$linux.git_rev
    ./scripts/update-git-status $linux .build/$linux.git_status
    # TODO: localmodconfig for i4lab
    ${MAKE} -f release.mk LINUX=$linux $linux/.config
done
