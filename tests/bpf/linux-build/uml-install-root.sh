#!/usr/bin/env bash
set -euo pipefail

DISK=$1
MNT=$2
HOSTNAME=$3
DEBOOTSTRAP_CACHE_DIR=$4

debootstrap --cache-dir=$DEBOOTSTRAP_CACHE_DIR bullseye $MNT http://deb.debian.org/debian

# Create an fstab file
echo "/dev/ubd0 / ext4 defaults 0 1" > $MNT/etc/fstab
echo "proc /proc proc defaults 0 0" >> $MNT/etc/fstab
echo "sysfs /sys sysfs defaults 0 0" >> $MNT/etc/fstab

# Based on Ubuntu 22:
echo "127.0.0.1	localhost
127.0.1.1	$HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
" > $MNT/etc/hosts

# Create the device file for the root file system and configure permissions
mknod --mode=660 $MNT/dev/ubd0 b 98 0
chown root:disk $MNT/dev/ubd0

# Create a hosts file
# echo "127.0.0.1 localhost" > $MNT/etc/hosts

# Configure network interfaces: eth0 using dhcp
# echo "auto lo" > $MNT/etc/network/interfaces
# echo "iface lo inet loopback" >> $MNT/etc/network/interfaces
# echo "auto eth0" >> $MNT/etc/network/interfaces
# echo "iface eth0 inet dhcp" >> $MNT/etc/network/interfaces

# Add first terminal and serial terminal to secure list
# echo "tty0" >> $MNT/etc/securetty
# echo "ttys/0" >> $MNT/etc/securetty

# Remove the other terminal events
# rm $MNT/etc/event.d/tty2
# rm $MNT/etc/event.d/tty3
# rm $MNT/etc/event.d/tty4
# rm $MNT/etc/event.d/tty5
# rm $MNT/etc/event.d/tty6
# rm $MNT/etc/udev/rules.d/75-persistent-net-generator.rules

yes | chroot $MNT passwd
