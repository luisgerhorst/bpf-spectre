#!/usr/bin/env bash
{
    set -euo pipefail
    set -x

    release="$1"
    cmdline="$2"

    sudo mv -n /etc/default/grub.d /etc/default/grub.d.$USER-backup || true
    sudo mv -n /etc/default/grub /etc/default/grub.$USER-backup || true

    echo "# Generated on $(hostname) in $(pwd) by $0, previous contents have been moved to ./grub[.d].$USER-backup
GRUB_DEFAULT=saved
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR='Debian'
GRUB_CMDLINE_LINUX_DEFAULT=''
GRUB_CMDLINE_LINUX='panic=30 crashkernel=256M nmi_watchdog=panic ${cmdline}'" \
    | sudo tee /etc/default/grub
    sudo update-grub

    # I don´t know where to get this value or why grub-reboot needs this in the first place.
    distro="Debian GNU/Linux"
    if ! grep "$distro" /boot/grub/grub.cfg > /dev/null
    then
       distro="GNU/Linux" # maybe thats on Debian 11
    fi
    if ! grep "$distro" /boot/grub/grub.cfg > /dev/null
    then
       distro="Ubuntu"
    fi

    # Sanity check, does the fallback boot entry exist?
    grep "Advanced options for ${distro}" /boot/grub/grub.cfg
    grep "${distro}, with Linux $(uname -r)" /boot/grub/grub.cfg

    menutitle="${distro}, with Linux ${release}"
    grep "${menutitle}" /boot/grub/grub.cfg

    # Set the fallback kernel in case the new custom kernel panics. That's also why
    # we set panic=30 and GRUB_DEFAULT=saved in grub config above.
    sudo grub-set-default "Advanced options for ${distro}>${distro}, with Linux $(uname -r)"

    # Set the new kernel, effective only for the next reboot. Otherwise it falls
    # back to the default kernel.
    sudo grub-reboot "Advanced options for ${distro}>${menutitle}"

    cat /boot/grub/grubenv
    # sudo reboot will boot the new kernel, but any subsequent reboot will again
    # boot the kernel we are currently running. This also includes reboots due to
    # panics in the new kernel.

    exit
}
