#!/bin/bash
{
    set -euo pipefail
    bash -n "$(command -v "$0")"
    set -x

    LINUX=$1
    MAKE=${MAKE:-make -j `getconf _NPROCESSORS_ONLN`}

    # Determine the kernel release our package will have.
    env - PATH=${PATH} KDEB_COMPRESS=xz LOCALVERSION=$(./scripts/linux-localversion.sh $LINUX) \
        ${MAKE} -C ${LINUX} include/config/kernel.release > /dev/null

    cat ${LINUX}/include/config/kernel.release
    exit
}
