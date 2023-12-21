#!/usr/bin/env bash
{
    set -euo pipefail
    shopt -s nullglob
    set -x

    set +e
    rs=$(dpkg -l \
        | grep --invert-match -e "$(uname -r)" \
        | grep -e "linux-.*-$USER+" \
        | awk '{ print $2 }' \
        | sort --reverse \
        | tail --lines=+4)
    sudo dpkg --remove $rs
    sudo dpkg --purge $rs
    set -e
    sudo --non-interactive apt-get -y autoremove
}
