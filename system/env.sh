# System under Test
export T=${T:-qemu-debian}
. ./targets/$T.sh

export TARGET_PREFIX=${TARGET_PREFIX:-/srv/scratch/$USER/.oseval/$(hostname)}
