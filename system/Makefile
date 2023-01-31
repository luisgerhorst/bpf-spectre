include env.mk

# Files to be merged into $(CONFIG) to create final $(LINUX)/.config
MERGE_CONFIGS ?=

RAMDISK=qemu-ramdisk.img

LINUX=linux
BZIMAGE=$(LINUX)/arch/x86_64/boot/bzImage

# Parallel make is OK.
MAKE += -j $(shell getconf _NPROCESSORS_ONLN)
export LD_LIBRARY_PATH=/usr/local/lib

# HACK: Before running the rules, update *.git_{rev|status} for each repo. We
# can then use them as dependencies to avoid recompilation of subprojects if
# nothing changed in their file tree.
REPOS := linux
_dummy := $(shell mkdir -p .build .build/bpf-samples .run .build/target-state/$(T))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-rev $(repo) .build/$(repo).git_rev))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-status $(repo) .build/$(repo).git_status))

LINUX_SRC = .build/linux.git_rev .build/linux.git_status
LINUX_TREE = linux/.config $(LINUX_SRC)
KERNEL_RELEASE = $(shell ./scripts/linux-release.sh $(LINUX))

# BUG: linux sync problem if making target with -j32
TARGET = .build/target-state/$(T)/kernel .build/target-state/$(T)/linux-tools .build/target-state/$(T)/linux-perf

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	$(MAKE) -C bpf-samples clean
	$(MAKE) -C linux clean
	rm -rfd .build .run

.PHONY: install-deps
install-deps:
	sudo apt install autossh dwarves

#
# Linux Files
#

# To initially create the file:
.build/merge_configs_value:
	echo -n '$(MERGE_CONFIGS)' > $@
# To detect when the variable value was changed:
_dummy := $(shell test "$(shell cat .build/merge_configs_value)" = '$(MERGE_CONFIGS)' \
	|| echo -n '$(MERGE_CONFIGS)' > .build/merge_configs_value)

$(LINUX)/.config: $(CONFIG) $(MERGE_CONFIGS) .build/merge_configs_value .build/linux.git_rev .build/linux.git_status
	KCONFIG_CONFIG=$(LINUX)/.config ./$(LINUX)/scripts/kconfig/merge_config.sh -m $(CONFIG) $(MERGE_CONFIGS)
	yes '' | $(MAKE) -C $(LINUX) oldconfig prepare
	$(eval KERNEL_RELEASE=$$(shell ./scripts/linux-release.sh $(LINUX)))

$(BZIMAGE): $(LINUX_TREE)
	flock .build/linux.lock $(MAKE) -C $(LINUX) bzImage vmlinux

#
# Linux Release Files
#
# Can be reused if they exist for $(KERNEL_RELEASE)
#
# TODO: Is there some generic cache for make, like ccache for cc?
#

.build/linux-pkg: $(LINUX_TREE)
	MAKE='$(MAKE)' flock .build/linux.lock \
		./scripts/make-linux-pkg $(LINUX) bindeb-pkg $@/ \
	&& touch $@

.build/linux-src.d: $(LINUX_TREE) $(BZIMAGE)
	rm -rfd $@ && mkdir -p $(dir $@)
	flock .build/linux.lock bash -c ' \
		pushd $(LINUX) && git commit --allow-empty -m "Makefile: staged" && git add -u && git commit --allow-empty -m "Makefile: unstaged" \
		&& popd && git clone --depth 1 $(LINUX) $@ \
	    && pushd $(LINUX) && git reset --soft HEAD^ && git reset && git reset --soft HEAD^ \
	'
	make -C $@ mrproper
	cp $(LINUX)/.config $@/.config
	cp $(LINUX)/vmlinux $@/vmlinux
	rm -rfd $@/.git
	touch $@

.build/linux-src/d.tar.gz: .build/linux-src.d
	mkdir -p $(dir $@)
	env -C $< tar cf - . | pigz > $@

LINUX_PERF_TARXZ=.build/linux-perf/linux-perf.tar.xz

$(LINUX_PERF_TARXZ): $(LINUX_TREE)
	rm -f linux/perf-*.tar.xz $@ \
	&& flock .build/linux.lock bash -c ' \
		cd $(LINUX) \
		&& git commit --allow-empty -m "Makefile: staged" && git add -u && git commit --allow-empty -m "Makefile: unstaged" \
		&& $(MAKE) perf-tarxz-src-pkg \
	    && git reset --soft HEAD^ && git reset && git reset --soft HEAD^ \
	' \
	&& mkdir -p $(dir $@) && mv -f $$(find linux -name 'perf-*.tar.xz') $@

#
# Debian VM Files
#

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
.run/debian.ssh_port: $(LINUX_TREE)
	T=qemu-debian ./scripts/target-scpsh 'systemctl poweroff' && echo "boot qemu with new kernel!" && exit 1

#
# Target SuT State
#

.build/target-state/qemu-debian: .run/debian.ssh_port
	touch $@

.build/target-state/faui49%/kernel: .build/linux-pkg $(wildcard .build/linux-pkg/*)
	./scripts/target-linux-deb-boot $< && touch $@

TS = .build/target-state/$(T)

$(TS)/linux-src: .build/linux-src/d.tar.gz .build/target-state/$(T)/kernel
	./scripts/target-scpsh 'sudo --non-interactive rm -rfd ../target_prefix/linux-src && mkdir -p ../target_prefix/linux-src'
	./scripts/target-scpsh -C $(dir $<) 'tar xf d.tar.gz --directory=../target_prefix/linux-src'
	touch $@

# selftests/bpf/bench requires CONFIG_DEBUG_INFO_BTF=y.
$(TS)/linux-tools: .build/target-state/$(T)/linux-src .build/target-state/$(T)/kernel
	./scripts/target-scpsh -C target-scripts "./linux-tools-install.sh"
	touch $@

# Could also be installed from ../target_prefix/linux-src on target, but this
# was copied from AnyCall and works.

# Installs custom's perf as perf_$(uname -r) into /usr/local to
# distinguish it from the systems regular perf. To be used by bench-scripts.
$(TS)/linux-perf: $(LINUX_PERF_TARXZ) .build/target-state/$(T)/kernel
	./scripts/target-scpsh 'sudo perf_$$(uname -r) stat true' \
	|| ./scripts/target-scpsh 'rm -rfd ../target_prefix/linux-perf/$$(uname -r) && mkdir -p ../target_prefix/linux-perf/$$(uname -r)' \
	&& ./scripts/target-scpsh -C $(dir $(LINUX_PERF_TARXZ)) 'tar xf linux-perf.tar.xz -C ../target_prefix/linux-perf/$$(uname -r)' \
	&& ./scripts/target-scpsh 'sudo apt-get install --yes flex bison libtraceevent-dev' \
	&& ./scripts/target-scpsh 'make -j $$(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-perf/$$(uname -r)/perf*/tools/perf' \
	&& ./scripts/target-scpsh 'sudo ln -sf $$(realpath ../target_prefix/linux-perf/$$(uname -r)/perf*/tools/perf/perf) /usr/local/bin/perf_$$(uname -r)'
	touch $@

#
# Linux Phony
#

.PHONY: bzImage
bzImage: $(BZIMAGE)

.PHONY: menuconfig
menuconfig: linux/.config
	$(MAKE) -C $(LINUX) menuconfig
	cp linux/.config $(CONFIG)

.PHONY: tags
tags: linux/.config
	$(MAKE) -C $(LINUX) tags

#
# QEMU Debian Phony
#

.PHONY: qemu
qemu: .build/$(VM).qcow2 $(BZIMAGE)
	./scripts/qemu-debian-boot .run/$(VM).ssh_port $^

.PHONY: ssh
ssh:
	ssh $(SSH_DEST) -p $(SSH_PORT) -o NoHostAuthenticationForLocalhost=true

.PHONY: qemu-shutdown
qemu-shutdown:
	T=qemu-debian ./scripts/target-scpsh 'systemctl poweroff'
