# System under Test
export T=${T:-faui49easy5}
. ./targets/$T.sh

# Where to persistenly store data on the target.
export PROJ_NAME=oseval
export TARGET_PREFIX=${TARGET_PREFIX:-/srv/scratch/$USER/.$PROJ_NAME/$(hostname -s)}
export LINUX_GIT_CHECKOUT=${LINUX_GIT_CHECKOUT:-HEAD-dirty}
export MERGE_CONFIGS=${MERGE_CONFIGS:-}
