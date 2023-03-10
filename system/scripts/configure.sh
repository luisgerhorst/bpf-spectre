#!/usr/bin/env bash
set -euo pipefail
set -x

LINUX_MAIN=${LINUX_MAIN:-linux-main}

pushd $LINUX_MAIN
current_branch=$(git rev-parse --abbrev-ref HEAD)
commit_ish=${LINUX_GIT_CHECKOUT:-${current_branch}}
git worktree add --force ../linux $commit_ish \
    || env -C ../linux git checkout --force --detach $commit_ish
popd

MAKE=${MAKE:-make}
MERGE_CONFIGS=${MERGE_CONFIGS:-}

if [ ! -e .build/merge_configs_value ] \
    || [ "$(cat .build/merge_configs_value)" != "${MERGE_CONFIGS}" ]
then
    echo -n "${MERGE_CONFIGS}" > .build/merge_configs_value
fi

for LINUX in linux linux-main
do
    ${MAKE} -f target.mk LINUX=$LINUX $LINUX/.config &
    ./scripts/update-git-rev $LINUX .build/$LINUX.git_rev &
    ./scripts/update-git-status $(repo) .build/$(repo).git_status &
done
wait
