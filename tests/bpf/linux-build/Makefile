T ?= qemu-debian
include targets/$(T).mk

RAMDISK=qemu-ramdisk.img

LINUX=linux
BZIMAGE=$(LINUX)/arch/x86_64/boot/bzImage

KERNEL_COMMIT := $(shell env -C $(LINUX) git rev-parse --short HEAD)
KERNEL_STATUS_MD5SUM = $(shell bash -c "env -C $(LINUX) git status -vv | awk '\$$1 != \"index\" { print }' | md5sum | cut -c -6")
KERNEL_CONFIG_MD5SUM = $(shell bash -c "md5sum $(CONFIG) | cut -c -6")
LOCALVERSION := -$(USER)+$(KERNEL_COMMIT)+$(KERNEL_STATUS_MD5SUM)+$(KERNEL_CONFIG_MD5SUM)
MAKE += -j $(shell getconf _NPROCESSORS_ONLN)
LINUX_MAKE := LD_LIBRARY_PATH=/usr/local/lib $(MAKE) LOCALVERSION=$(LOCALVERSION)

# HACK: Before running the rules, update *.git_{rev|status} for each repo. We
# can then use them as dependencies to avoid recompilation of subprojects if
# nothing changed in their file tree.
REPOS := linux
_dummy := $(shell mkdir -p .build .run)
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-rev $(repo) .build/$(repo).git_rev))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-status $(repo) .build/$(repo).git_status))

# Linux Files

linux/.config: $(CONFIG) .build/linux.git_rev .build/linux.git_status
	cp $< $@
	yes '' | $(LINUX_MAKE) -C $(LINUX) oldconfig
	$(LINUX_MAKE) -C $(LINUX) prepare

$(BZIMAGE): linux/.config .build/linux.git_rev .build/linux.git_status
	$(LINUX_MAKE) -C linux bzImage

# Debian Files

.build/qemu-debian-netboot.tar.gz:
	curl --location --output $@ https://deb.debian.org/debian/dists/buster/main/installer-amd64/current/images/netboot/netboot.tar.gz

.build/$(VM).clean-install/hda.qcow2: .build/qemu-debian-netboot.tar.gz qemu-debian-preseed.cfg
	./scripts/qemu-debian-install $(dir $@) "" $^

# You likely do not want to use this as a dependency for make targets as it's
# always changing when a VM is running.
.build/$(VM).qcow2: .build/$(VM).clean-install/hda.qcow2
	cp $< $@

# Linux Phony

.PHONY: bzImage
bzImage: $(BZIMAGE)

.PHONY: menuconfig
menuconfig: linux/.config
	$(LINUX_MAKE) -C $(LINUX) menuconfig
	cp linux/.config $(CONFIG)

.PHONY: tags
tags: linux/.config
	$(LINUX_MAKE) -C $(LINUX) tags

# Debian Phony

.PHONY: qemu
qemu: .build/$(VM).qcow2 $(BZIMAGE)
	./scripts/qemu-debian-boot .run/$(VM).ssh_port $^

.PHONY: qemu-ssh
qemu-ssh:
	ssh $(SSH_DEST) -p $(SSH_PORT) -o NoHostAuthenticationForLocalhost=true

.PHONY: qemu-shutdown
qemu-shutdown:
	T=qemu-debian ./scripts/target-scpsh 'systemctl poweroff'
