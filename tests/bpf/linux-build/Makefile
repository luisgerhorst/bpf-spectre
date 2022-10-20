.PHONY: all
all: .build/img

# https://www.kernel.org/doc/html/latest/virt/uml/user_mode_linux_howto_v2.html
# https://help.ubuntu.com/community/UserModeLinux
.build/img: Makefile | .build $(shell pwd)/.build/debootstrap-cache-dir
	./uml-install.sh $@ .mnt uml-vm $(shell pwd)/.build/debootstrap-cache-dir

.PHONY: boot
boot:
	rm -f .build/cow
	./linux/linux mem=1G ubd0=.build/cow,.build/img root=/dev/ubd0 con=null con0=null,fd:2 con1=fd:0,fd:1

.build:
	mkdir -p $@

$(shell pwd)/.build/debootstrap-cache-dir:
	mkdir -p $@

.PHONY: clean
clean:
	sudo umount --force .build/mnt
	rm -rfd .build
