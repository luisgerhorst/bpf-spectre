include env.mk

# Files to be merged into $(CONFIG) to create final $(LINUX)/.config
MERGE_CONFIGS ?=

RAMDISK := qemu-ramdisk.img

LINUX ?= linux
BZIMAGE := $(LINUX)/arch/x86_64/boot/bzImage

# Should be in a directory that disappears on reboot to invalidate state of VMM
# virtual machines.
export TS := .run/$(T)-$(shell cat /proc/sys/kernel/random/boot_id)

export LD_LIBRARY_PATH := /usr/local/lib

_dummy := $(shell mkdir -p .build .build/bpf-samples $(TS))

.PHONY: all
all: bzImage .build/linux-src/d.tar.gz .build/linux-pkg \
	.build/$(VM).qcow2

.PHONY: target
target: .build/linux-pkg
	MAKE='$(MAKE)' ./scripts/make-target.sh $(TS)/linux-tools

LINUX_SRC := .build/$(LINUX).git_rev .build/$(LINUX).git_status
LINUX_TREE := $(LINUX)/.config $(LINUX_SRC)

# KERNEL_RELEASE := $(shell ./scripts/linux-release.sh $(LINUX))
BCC_LOCALVERSION := $(shell cat .build/bcc.localversion)

#
# Linux Files
#

$(BZIMAGE): .build/linux-bins

# Building the selftests here assumes your glibc is <= the target glibc.
.build/linux-bins: $(LINUX_TREE) release.mk
	flock .build/linux.lock $(MAKE) -C $(LINUX) vmlinux headers
	flock .build/linux.lock $(MAKE) \
		SKIP_TARGETS="arm64 ia64 powerpc sparc64 riscv64 x86 drivers/s390x/uvdevice sgx memfd mqueue capabilities hid alsa" \
	 	-C $(LINUX)/tools/testing/selftests gen_tar
	flock .build/linux.lock $(MAKE) -C $(LINUX) bzImage
	touch $@

#
# Linux Release Files
#
# Can be reused if they exist for $(KERNEL_RELEASE)
#
# TODO: Is there some generic cache for make, like ccache for cc?
#

.build/linux-pkg: $(LINUX_TREE)
	MAKE='$(MAKE)' flock .build/linux.lock ./scripts/make-linux-pkg $(LINUX) bindeb-pkg $@/
	touch $@ $@/*

# TODO: use git	worktree add/archive/export-index https://stackoverflow.com/questions/160608/do-a-git-export-like-svn-export/160719#160719
.build/linux-src.d: .build/linux-bins release.mk
	rm -rfd $@ && mkdir -p $(dir $@)
	flock .build/linux.lock bash -c ' \
		pushd $(LINUX) && git commit --allow-empty -m "Makefile: staged" && git add -u && git commit --allow-empty -m "Makefile: unstaged" \
		&& popd && git clone --depth 1 $(LINUX) $@ \
	    && pushd $(LINUX) && git reset --soft HEAD^ && git reset && git reset --soft HEAD^ \
	'
	$(MAKE) -C $@ mrproper
	cp $(LINUX)/.config $@/.config
	cp $(LINUX)/vmlinux $@/vmlinux
	rm -rfd $@/.git
	touch $@

# TODO: Remove as now supported by target-scpsh
.build/linux-src/d.tar.gz: .build/linux-src.d
	mkdir -p $(dir $@)
	env -C $< tar cf - . | pigz > $@

#
# Debian VM Files
#

# TODO: Replace with GNOME Boxes and regular grub-based reboot.
.build/qemu-debian-netboot.tar.gz:
	curl --location --output $@ https://deb.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/netboot.tar.gz

# The default root password is empty. This is still secure because sshd defaults
# to "PermitRootLogin prohibit-password". During install, the host authorized
# keys are copied to the guest.
.build/$(VM).clean-install/hda.qcow2: .build/qemu-debian-netboot.tar.gz qemu-debian-preseed.cfg
	./scripts/qemu-debian-install $(dir $@) "" $^

# You likely do not want to use this as a dependency for make targets as it's
# always changing when a VM is running.
.build/$(VM).qcow2: .build/$(VM).clean-install/hda.qcow2
	cp $< $@

# Expected to fail if booted qemu runs outdated kernel.
.build/debian.ssh_port: $(LINUX_TREE)
	T=qemu-debian ./scripts/target-scpsh 'systemctl poweroff' && echo "boot qemu with new kernel!" && exit 1

#
# Target SuT State
#

$(TS)/linux-src: .build/linux-src/d.tar.gz $(TS)/kernel
	./scripts/target-scpsh 'sudo --non-interactive rm -rfd ../target_prefix/linux-src && mkdir -p ../target_prefix/linux-src'
	./scripts/target-scpsh -C $(dir $<) 'tar xf d.tar.gz --directory=../target_prefix/linux-src'
	mkdir -p $(dir $@) && touch $@

$(TS)/bcc: .build/bcc.git_rev .build/bcc.git_status $(TS)/kernel
	./scripts/target-scpsh -C bpf-samples/external/bcc "sudo cp --force --recursive . ../target_prefix/bcc"
	mkdir -p $(dir $@) && touch $@

LOXILB_D=../target_prefix/loxilb
$(TS)/loxilb: .build/loxilb.git_rev .build/loxilb.git_status $(TS)/kernel release.mk
	./scripts/target-scpsh -C bpf-samples/external/loxilb "rm -rfd $(LOXILB_D) && sudo cp --force --recursive . $(LOXILB_D) && cd $(LOXILB_D) && sudo chown -R $$USER . && rm -rfd .git && git init . && git add . > /dev/null && git commit -m 'dummy commit for act' > /dev/null && git remote add origin git@github.com:luisgerhorst/loxilb.git"
	mkdir -p $(dir $@) && touch $@

# selftests/bpf/bench requires CONFIG_DEBUG_INFO_BTF=y.
KSD=../target_prefix/kselftest
$(TS)/linux-tools: $(TS)/bcc $(TS)/loxilb $(TS)/linux-src $(TS)/kernel target-scripts/linux-tools-install.sh .build/linux-bins
	./scripts/target-scpsh -C $(LINUX)/tools/testing/selftests/kselftest_install/kselftest-packages "rm -rfd $(KSD) && mkdir -p $(KSD) && tar xf kselftest.tar.gz --directory=$(KSD)"
	./scripts/target-scpsh -C target-scripts "BCC_LOCALVERSION=$(BCC_LOCALVERSION) ./linux-tools-install.sh"
	mkdir -p $(dir $@) && touch $@

#
# QEMU Debian Phony
#

.PHONY: qemu
qemu: .build/$(VM).qcow2 $(BZIMAGE)
	./scripts/qemu-debian-boot .build/$(VM).ssh_port $^

.PHONY: ssh
ssh:
	ssh $(SSH_DEST) -p $(SSH_PORT) -o NoHostAuthenticationForLocalhost=true

.PHONY: qemu-shutdown
qemu-shutdown:
	T=qemu-debian ./scripts/target-scpsh 'systemctl poweroff'
