# System under Test
export T=${T:-faui49easy4}
. ./targets/$T.sh

# Where to persistenly store data on the target.
export PROJ_NAME=oseval
export TARGET_PREFIX=${TARGET_PREFIX:-/srv/scratch/$USER/.$PROJ_NAME/$(hostname -s)}
export LINUX_GIT_CHECKOUT=${LINUX_GIT_CHECKOUT:-HEAD-dirty}
export MERGE_CONFIGS=${MERGE_CONFIGS:-}

export PATH=/usr/lib/ccache:/usr/lib/llvm-16/bin:$PATH
export CCACHE_DIR=$(realpath $(realpath .)/../../.ccache)
export CCACHE_MAXSIZE=$(expr $(vmstat -s | grep -i 'K total memory' | sed 's/ *//' | cut --delimiter=' ' -f1) '/' 1024)Mi
