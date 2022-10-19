#!/usr/bin/env bash
set -euo pipefail
set -x

LINUX=$1
TARGET=$2
DST=$3

# KERNEL_COMMIT=`env -C ${LINUX} git rev-parse --short HEAD`
# KERNEL_CONFIG_MD5SUM=`md5sum ${LINUX}/.config | awk '{ print $1 }'`
# LOCALVERSION=${LOCALVERSION:--${USER}+${KERNEL_COMMIT}+${KERNEL_CONFIG_MD5SUM}}
MAKE=${MAKE:-make -j `getconf _NPROCESSORS_ONLN`}

# Determine the kernel release and build version our package will have.
env - PATH=${PATH} ${MAKE} -C ${LINUX} include/config/kernel.release
KERNEL_RELEASE=`cat ${LINUX}/include/config/kernel.release`
if [ -f ${LINUX}/.version ]
then
    KBUILD_BUILD_VERSION=`cat ${LINUX}/.version`
else
    KBUILD_BUILD_VERSION=1
fi

env - CCACHE_DIR=${CCACHE_DIR} PATH=${PATH} \
    ${MAKE} -C ${LINUX} ${TARGET}
ccache -s
