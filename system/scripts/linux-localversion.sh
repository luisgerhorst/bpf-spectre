#!/bin/bash
{
    set -euo pipefail
    bash -n "$(command -v "$0")"
    set -x

    LINUX=$1

    # Do this here and not in system's Makefile because the Makefile may change linux/.config.
    CONFIG=$LINUX/.config
    KERNEL_COMMIT=$(env -C ${LINUX} git rev-parse --short HEAD)
    KERNEL_STATUS_MD5SUM=$(env -C $LINUX git status -vv | awk '$1 != "index" { print }' | md5sum | cut -c -6)
    KERNEL_CONFIG_MD5SUM=$(md5sum $CONFIG | cut -c -6)
    LOCALVERSION=-$USER+$KERNEL_COMMIT+$KERNEL_STATUS_MD5SUM+$KERNEL_CONFIG_MD5SUM

    echo "$LOCALVERSION"
    exit
}
