#!/bin/bash
{
    set -euo pipefail
    bash -n "$(command -v "$0")"
    set -x

    LINUX=$1
    MAKE=${MAKE:-make}

    # Do this here and not in system's Makefile because the Makefile may change linux/.config.

    $MAKE -C $LINUX savedefconfig > /dev/null

    KERNEL_COMMIT=$(env -C ${LINUX} git rev-parse --short HEAD | cut --characters=1-6)
    diff="$(env -C $LINUX git diff)"
    KERNEL_STATUS_MD5SUM="+$(echo "$diff" | md5sum | cut --characters=1-6)"
    if test "$diff" = ""
    then
        KERNEL_STATUS_MD5SUM=""
    fi
    KERNEL_CONFIG_MD5SUM=$(cat $LINUX/defconfig | md5sum | cut --characters=1-6)
    LOCALVERSION=-$USER+$KERNEL_COMMIT+$KERNEL_CONFIG_MD5SUM$KERNEL_STATUS_MD5SUM

    # TODO: Write to linux/localversion, set var to ""
    echo "$LOCALVERSION"
    exit
}
