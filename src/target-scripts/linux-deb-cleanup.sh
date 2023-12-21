#!/usr/bin/env bash
{
    set -euo pipefail
    shopt -s nullglob
    set -x

    SUDO="sudo --non-interactive --preserve-env=PATH"
    APT="apt-get --assume-yes"

    set +e
    rs=$(dpkg -l \
        | grep --invert-match -e "$(uname -r)" \
        | grep -e "linux-.*-$USER+" \
        | awk '{ print $2 }' \
        | sort --reverse \
        | tail --lines=+4)
    $SUDO $APT remove --purge $rs
    set -e
    $SUDO $APT autoremove
}
