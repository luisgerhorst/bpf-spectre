#!/bin/bash
{
    set -euo pipefail
    bash -n "$(command -v "$0")"
    set -x

    LINUX=$1

    # Do this here and not in system's Makefile because the Makefile may change linux/.config.
    CONFIG=$LINUX/.config
    KERNEL_COMMIT=$(env -C ${LINUX} git rev-parse --short HEAD | cut --characters=1-6)
    KERNEL_STATUS_MD5SUM=$(env -C $LINUX git status -vv | awk '$1 != "index" { print }' | md5sum)
    KERNEL_CONFIG_MD5SUM=$(md5sum $CONFIG)
    LOCALVERSION=-$USER+$KERNEL_COMMIT+$(echo $KERNEL_STATUS_MD5SUM+$KERNEL_CONFIG_MD5SUM | md5sum | cut --characters=1-6)

    echo "$LOCALVERSION"
    exit
}
