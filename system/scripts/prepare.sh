#!/usr/bin/env bash
set -euo pipefail
set -x

LINUX=${LINUX:-linux-main}

pushd $LINUX
current_branch=$(git rev-parse --abbrev-ref HEAD)
commit_ish=${LINUX_GIT_CHECKOUT:-${current_branch}}
git worktree add --force ../linux $commit_ish \
    || env -C ../linux git checkout --force --detach $commit_ish
popd

MERGE_CONFIGS=${MERGE_CONFIGS:-}

if [ ! -e .build/merge_configs_value ] \
    || [ "$(cat .build/merge_configs_value)" != "${MERGE_CONFIGS}" ]
then
    echo -n "${MERGE_CONFIGS}" > .build/merge_configs_value
fi

${MAKE} -f target.mk LINUX=linux-main linux-main/.config
${MAKE} -f target.mk LINUX=linux linux/.config
