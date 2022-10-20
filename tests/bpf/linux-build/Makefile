VM=debian/hda

T ?= vm
include targets/$(T).mk

RAMDISK=qemu-ramdisk.img

LINUX=linux
BZIMAGE=$(LINUX)/arch/x86_64/boot/bzImage
CONFIG=configs/qemu-debian

KERNEL_COMMIT := $(shell env -C $(LINUX) git rev-parse --short HEAD)
KERNEL_STATUS_MD5SUM = $(shell bash -c "env -C $(LINUX) git status -vv | awk '\$$1 != \"index\" { print }' | md5sum | cut -c -6")
KERNEL_CONFIG_MD5SUM = $(shell bash -c "md5sum $(CONFIG) | cut -c -6")
LOCALVERSION := -$(USER)+$(KERNEL_COMMIT)+$(KERNEL_STATUS_MD5SUM)+$(KERNEL_CONFIG_MD5SUM)
MAKE += -j $(shell getconf _NPROCESSORS_ONLN)
LINUX_MAKE := LD_LIBRARY_PATH=/usr/local/lib $(MAKE) LOCALVERSION=$(LOCALVERSION)
LINUX_PERF_TARXZ=.build/linux-perf/linux-perf.tar.xz

# HACK: Before running the rules, update *.git_{rev|status} for each repo. We
# can then use them as dependencies to avoid recompilation of subprojects if
# nothing changed in their file tree.
REPOS := linux
_dummy := $(shell mkdir -p .build)
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-rev $(repo) .build/$(repo).git_rev))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-status $(repo) .build/$(repo).git_status))

.PHONY: tags
tags: linux/.config
	$(LINUX_MAKE) -C linux tags

linux/.config: $(CONFIG) .build/linux.git_rev .build/linux.git_status
	cp $< $@
	yes '' | $(LINUX_MAKE) -C linux oldconfig
	$(LINUX_MAKE) -C linux prepare

.PHONY: menuconfig
menuconfig: linux/.config
	$(LINUX_MAKE) -C linux menuconfig
	cp linux/.config $(CONFIG)

.PHONY: bzImage
bzImage: $(BZIMAGE)

$(BZIMAGE): linux/.config .build/linux.git_rev .build/linux.git_status
	$(LINUX_MAKE) -C linux bzImage

.build/deb-linux: linux/.config .build/linux.git_rev .build/linux.git_status
	MAKE='$(LINUX_MAKE)' ./scripts/make-linux $(LINUX) bindeb-pkg $@/
	touch $@

.build/target-install-bpftool:

$(RAMDISK):
	/usr/sbin/mkinitramfs -o $(RAMDISK)

# Terminate with C-a x
.PHONY: qemu-ramdisk
qemu-ramdisk: $(BZIMAGE) $(RAMDISK)
	qemu-system-x86_64 -kernel $(BZIMAGE) -nographic -append "console=ttyS0 nokaslr loglevel=15" -initrd $(RAMDISK) -m 1024

qemu-debian-netboot.tar.gz:
	curl --location --output $@ https://deb.debian.org/debian/dists/buster/main/installer-amd64/current/images/netboot/netboot.tar.gz

# Ready to be accessed using 'ssh root@localhost -p $(cat ssh_port_file)'.
$(VM).qcow2: qemu-debian-netboot.tar.gz qemu-debian-preseed.cfg
	./scripts/qemu-debian-install debian "" $^

# You likely do not want to use this as a dependency for make targets as it's
# always changing when a VM is running.
$(VM)-dirty.qcow2: $(VM).qcow2
	cp $< $@

.PHONY: qemu
qemu: $(VM)-dirty.qcow2 $(BZIMAGE)
	./scripts/qemu-debian-boot $(VM)-dirty $(BZIMAGE)

.PHONY: qemu-ssh
qemu-ssh:
	ssh root@localhost -p $(shell cat $(VM)-dirty.ssh_port) -o NoHostAuthenticationForLocalhost=true

.PHONY: qemu-shutdown
qemu-shutdown:
	./scripts/qemu-debian-shutdown $(VM)-dirty
