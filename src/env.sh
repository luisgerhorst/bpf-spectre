# System under Test
export T=${T:-qemu-debian}
. ./targets/$T.sh

# Where to persistenly store data on the target.
export PROJ_NAME=oseval
export TARGET_PREFIX=${TARGET_PREFIX:-/srv/scratch/$USER/.$PROJ_NAME/$(hostname -s)}
