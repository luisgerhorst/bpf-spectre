.PHONY: all
all: .build/img

# https://www.kernel.org/doc/html/latest/virt/uml/user_mode_linux_howto_v2.html
# https://help.ubuntu.com/community/UserModeLinux
.build/img: Makefile | .build
	./uml-install.sh $@ .mnt

.PHONY: boot
boot:
	./linux/linux

.build:
	mkdir -p $@

.PHONY: clean
clean:
	sudo umount --force .build/mnt
	rm -rfd .build
