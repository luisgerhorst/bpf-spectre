include env.mk

# Files to be merged into $(CONFIG) to create final $(LINUX)/.config
MERGE_CONFIGS ?=

RAMDISK=qemu-ramdisk.img

LINUX=linux
BZIMAGE=$(LINUX)/arch/x86_64/boot/bzImage

# Parallel make is OK for subdirectories. However, parallel target-scpsh calls may be
# problematic because of apt, therefore only -j1 for this Makefile.
MAKE += -j $(shell getconf _NPROCESSORS_ONLN)
LINUX_MAKE := LD_LIBRARY_PATH=/usr/local/lib $(MAKE)

# HACK: Before running the rules, update *.git_{rev|status} for each repo. We
# can then use them as dependencies to avoid recompilation of subprojects if
# nothing changed in their file tree.
REPOS := linux
_dummy := $(shell mkdir -p .build .build/bpf-samples .run .build/target-state/$(T))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-rev $(repo) .build/$(repo).git_rev))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-status $(repo) .build/$(repo).git_status))

LINUX_SRC = .build/linux.git_rev .build/linux.git_status
LINUX_TREE := linux/.config $(LINUX_SRC)

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
	sudo apt install autossh

#
# Linux Files
#

# To initially create the file.
.build/merge_configs_value:
	echo -n '$(MERGE_CONFIGS)' > $@
#
# To detect when the variable value was changed.
_dummy := $(shell test "$(shell cat .build/merge_configs_value)" = '$(MERGE_CONFIGS)' \
	|| echo -n '$(MERGE_CONFIGS)' > .build/merge_configs_value)

$(LINUX)/.config: $(CONFIG) $(MERGE_CONFIGS) .build/merge_configs_value .build/linux.git_rev .build/linux.git_status
	KCONFIG_CONFIG=$(LINUX)/.config ./$(LINUX)/scripts/kconfig/merge_config.sh -m $(CONFIG) $(MERGE_CONFIGS)
	yes '' | $(LINUX_MAKE) -C $(LINUX) oldconfig
	$(LINUX_MAKE) -C $(LINUX) prepare

$(BZIMAGE): $(LINUX_TREE)
	$(LINUX_MAKE) -C $(LINUX) bzImage vmlinux

.build/linux-bindeb: $(LINUX_TREE)
	MAKE='$(LINUX_MAKE)' ./scripts/make-linux-deb $(LINUX) bindeb-pkg $@/
	touch $@

.build/linux-src.d: $(LINUX_TREE) $(BZIMAGE)
	rm -rfd $@ && mkdir -p $(dir $@)
	cd $(LINUX) && git commit --allow-empty -m "Makefile: staged" && git add -u && git commit --allow-empty -m "Makefile: unstaged"
	git clone --depth 1 $(LINUX) $@
	cd $(LINUX) && git reset --soft HEAD^ && git reset && git reset --soft HEAD^
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
	rm -f linux/perf-*.tar.xz $@
	cd $(LINUX) && git commit --allow-empty -m "Makefile: staged" && git add -u && git commit --allow-empty -m "Makefile: unstaged"
	$(LINUX_MAKE) -C $(LINUX) perf-tarxz-src-pkg
	mkdir -p $(dir $@)
	mv -f $$(find linux -name 'perf-*.tar.xz') $@
	cd $(LINUX) && git reset --soft HEAD^ && git reset && git reset --soft HEAD^

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

#
# Target SuT State
#

# Expected to fail if booted qemu runs outdated kernel.
.run/debian.ssh_port: $(LINUX_TREE)
	T=qemu-debian ./scripts/target-scpsh 'systemctl poweroff' && echo "boot qemu with new kernel!" && exit 1

.build/target-state/$(T)/deb-install: .build/linux-bindeb $(wildcard .build/linux-bindeb/*.deb)
	./scripts/target-scpsh 'sudo --non-interactive dpkg -r $(dpkg -l | awk \'{ print $2 }\' | grep -e "linux-headers")' || true
	./scripts/target-scpsh 'sudo dpkg -r $(dpkg -l | awk \'{ print $2 }\' | grep -e "linux-image" | grep -e "-dbg")' || true
	./scripts/target-scpsh 'sudo apt-get -y autoremove' || true
	./scripts/target-scpsh -C $< 'cp -rdf . ../target_prefix/deb'
	./scripts/target-scpsh 'sudo --non-interactive dpkg -i ../target_prefix/deb/*.deb' || true # announce deps
	./scripts/target-scpsh 'sudo apt-get -y --fix-broken install' # install deps
	./scripts/target-scpsh 'sudo dpkg -i ../target_prefix/deb/*.deb'
	touch $@

.build/target-state/qemu-debian/kernel: .run/debian.ssh_port
	touch $@

.build/target-state/faui49%/kernel: .build/target-state/faui49%/deb-install
	./scripts/target-grub-boot -r "$$(cat .build/linux-bindeb/kernel.release)" -t $@

# TODO: Use debian source package instead.
.build/target-state/$(T)/linux-src: .build/linux-src/d.tar.gz
	./scripts/target-scpsh 'sudo --non-interactive rm -rfd ../target_prefix/linux-src && mkdir -p ../target_prefix/linux-src'
	./scripts/target-scpsh -C $(dir $<) 'tar xf d.tar.gz --directory=../target_prefix/linux-src'
	touch $@

.build/target-state/$(T)/linux-tools: .build/target-state/$(T)/linux-src
	./scripts/target-scpsh 'sudo --non-interactive apt-get --assume-yes install clang libcap-ng-dev libfuse-dev libcpupower-dev libpci-dev libcap-dev make gcc binutils-dev libreadline-dev libbison-dev flex libelf-dev'
	./scripts/target-scpsh 'sudo make STATIC=true -j $$(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools bpf_install'
	./scripts/target-scpsh 'sudo make STATIC=true -j $$(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools cpupower_install turbostat_install' || true
	./scripts/target-scpsh '\
		make -j $$(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src  oldconfig \
		&& make -j $$(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src prepare \
		&& make \
			SKIP_TARGETS="alsa memfd net netfilter vm x86" FORCE_TARGETS=1 TEST_GEN_PROGS= \
			-j $$(getconf _NPROCESSORS_ONLN) \
			-k -C ../target_prefix/linux-src/tools/testing/selftests \
			install \
		|| ../target_prefix/linux-src/tools/testing/selftests/bpf/bench --help'
	touch $@

# Could also be installed from ../target_prefix/linux-src on target, but this
# was copied from AnyCall and works.
#
# Installs custom's perf as perf_$(uname -r) into /usr/local to
# distinguish it from the systems regular perf. To be used by bench-scripts.
.build/target-state/$(T)/linux-perf: $(LINUX_PERF_TARXZ)
	./scripts/target-scpsh 'rm -rfd ../target_prefix/linux-perf'
	./scripts/target-scpsh 'mkdir -p ../target_prefix/linux-perf'
	./scripts/target-scpsh -C $(dir $(LINUX_PERF_TARXZ)) 'tar xf linux-perf.tar.xz -C ../target_prefix/linux-perf'
	./scripts/target-scpsh 'sudo apt-get install --yes flex bison libtraceevent-dev'
	./scripts/target-scpsh 'make -j $$(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-perf/perf*/tools/perf'
	./scripts/target-scpsh 'sudo ln -sf $$(realpath ../target_prefix/linux-perf/perf*/tools/perf/perf) /usr/local/bin/perf_$$(uname -r)'
	touch $@

#
# BPF Samples
#
# Convenience for testing. Not included in all-Target because it takes long and
# is not required by most bench-scripts. Consider using './bench/run.sh --suite
# bpf' instead.
#

.PHONY: bpf-samples-all
bpf-samples-all:
	$(MAKE) -C bpf-samples all

.build/bpf-samples/%.test-result.yaml: bpf-samples/prog/%.bpf.s $(TARGET) | bpf-samples-all
	rm -rfd .build/bpf-samples/$*.*
	./scripts/target-scpsh -C bpf-samples/.build/$*.bpftool.input -o .build/bpf-samples/$*.bpftool-priv \
		'./bpftool.sh $*.bpf.o --drop= 2>&1 | tee ../result_dir/log'
	./scripts/target-scpsh -C bpf-samples/.build/$*.bpftool.input -o .build/bpf-samples/$*.bpftool-unpriv \
		'./bpftool.sh $*.bpf.o "--drop=cap_sys_admin --drop=cap_perfmon" 2>&1 | tee ../result_dir/log'
	./bpf-samples/summarize-test-result.py \
		.build/bpf-samples/$*.test-result.yaml \
		bpf-samples/.build/$*.spectector.log \
		.build/bpf-samples/$*.bpftool \
		bpf-samples/prog/$*.bpf.s \
		bpf-samples/.build/$*.perf

PREFIX = bpf-samples
include bpf-samples/prog.mk

.build/bpf-samples.tsv.gz: $(patsubst $(PREFIX)/prog/%.bpf.s,.build/bpf-samples/%.test-result.yaml,$(ALL_S)) | bpf-samples-all
	./bpf-samples/join-yamls.py --output .build/bpf-samples.tsv.gz \
		--yamls $^

.PHONY: bpf-samples
bpf-samples: .build/bpf-samples.tsv.gz

#
# Linux Phony
#

.PHONY: bzImage
bzImage: $(BZIMAGE)

.PHONY: menuconfig
menuconfig: linux/.config
	$(LINUX_MAKE) -C $(LINUX) menuconfig
	cp linux/.config $(CONFIG)

.PHONY: tags
tags: linux/.config
	$(LINUX_MAKE) -C $(LINUX) tags

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
