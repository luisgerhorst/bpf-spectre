#!/usr/bin/env bash
set -euo pipefail
set -x

if test -e /etc/default/grub.$USER-backup
then
    sudo mv -f /etc/default/grub /etc/default/grub.$USER-release-backup
    sudo mv -f /etc/default/grub.$USER-backup /etc/default/grub
fi

if test -d /etc/default/grub.d.$USER-backup
then
    sudo mv -f /etc/default/grub.d /etc/default/grub.d.$USER-release-backup
    sudo mv -f /etc/default/grub.d.$USER-backup /etc/default/grub.d
fi

LLVM_VERSION=16
sudo apt remove clang-${LLVM_VERSION} clangd-${LLVM_VERSION} libclang-${LLVM_VERSION}-dev clang-tools-${LLVM_VERSION} clang-tidy-${LLVM_VERSION}
sudo apt --fix-broken install

set +e
rs=$(dpkg -l \
    | grep -e "linux-.*-$USER+" \
    | awk '{ print $2 }' \
    | sort --reverse \
    | tail --lines=+5)
sudo dpkg --remove $rs
sudo dpkg --purge $rs
set -e
sudo --non-interactive apt-get -y autoremove

sudo update-grub
set-system-mode normal || true
sudo systemctl enable run-fai.timer
sudo systemctl enable fai-boot.service
