#!/usr/bin/env bash
set -euo pipefail

DISK=$1
MNT=$2

# Create an empty file to contain the root filesystem
dd if=/dev/zero of=$DISK bs=1 seek=8G count=1

# Create the filesystem on the file
mkfs.ext4 $DISK

# Mount the filesystem
mkdir -p $MNT
sudo mount -o loop $DISK $MNT

sudo ./uml-install-root.sh $@

sudo unmount $MNT
