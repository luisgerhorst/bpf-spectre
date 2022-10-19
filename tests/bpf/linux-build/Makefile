.PHONY: all
all: .build/disk

# https://www.kernel.org/doc/html/latest/virt/uml/user_mode_linux_howto_v2.html
.build/disk.debootstrap: | .build
	rm -rfd $@
	dd if=/dev/zero of=$@ bs=1 count=1 seek=16G
	mkfs.ext4 $@
	mkdir -p .build/mnt
	sudo mount $@ .build/mnt
	sudo debootstrap bullseye .build/mnt http://deb.debian.org/debian
	sudo umount .build/mnt

.build/disk.config: .build/disk.debootstrap Makefile
	cp -f $< $@
	sudo mount $@ .build/mnt
	yes | sudo chroot .build/mnt passwd
	echo "/dev/ubd0   ext4    discard,errors=remount-ro  0       1"	| sudo chroot .build/mnt tee /etc/fstab
	sudo umount .build/mnt

.PHONY: boot
boot:
	./linux/linux

.build:
	mkdir -p $@

.PHONY: clean
clean:
	sudo umount --force .build/mnt
	rm -rfd .build
