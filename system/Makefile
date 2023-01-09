include env.mk

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
_dummy := $(shell mkdir -p .build .build/bpf-samples .run .build/target-state/$(T))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-rev $(repo) .build/$(repo).git_rev))
_dummy := $(foreach repo,$(REPOS),$(shell ./scripts/update-git-status $(repo) .build/$(repo).git_status))

LINUX_TREE := linux/.config .build/linux.git_rev .build/linux.git_status

TARGET = .build/target-state/$(T)/kernel .build/target-state/$(T)/linux-tools .build/target-state/$(T)/linux-perf

.PHONY: all
all: bpf-samples $(TARGET)

.PHONY: clean
clean:
	$(MAKE) -C bpf-samples clean
	$(MAKE) -C linux clean
	rm -rfd .build .run

#
# Linux Files
#

$(LINUX)/.config: $(CONFIG) .build/linux.git_rev .build/linux.git_status
	cp $< $@
	yes '' | $(LINUX_MAKE) -C $(LINUX) oldconfig
	$(LINUX_MAKE) -C $(LINUX) prepare

$(BZIMAGE): $(LINUX_TREE)
	$(LINUX_MAKE) -C $(LINUX) bzImage

.build/linux-bindeb: $(LINUX_TREE)
	MAKE='$(LINUX_MAKE)' ./scripts/make-linux-deb $(LINUX) bindeb-pkg $@/
	touch $@

.build/linux-src.d: $(LINUX_TREE)
	rm -rfd $@ && mkdir -p $(dir $@)
	cd $(LINUX) && git commit --allow-empty -m "Makefile: staged" && git add -u && git commit --allow-empty -m "Makefile: unstaged"
	git clone --depth 1 $(LINUX) $@
	cd $(LINUX) && git reset --soft HEAD^ && git reset && git reset --soft HEAD^
	make -C $@ mrproper
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
# Debian Files
#

.build/qemu-debian-netboot.tar.gz:
	curl --location --output $@ https://deb.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/netboot.tar.gz

.build/$(VM).clean-install/hda.qcow2: .build/qemu-debian-netboot.tar.gz qemu-debian-preseed.cfg
	./scripts/qemu-debian-install $(dir $@) "" $^

# You likely do not want to use this as a dependency for make targets as it's
# always changing when a VM is running.
.build/$(VM).qcow2: .build/$(VM).clean-install/hda.qcow2
	cp $< $@

#
# Target State
#

.build/target-state/$(T)/linux-src: .build/linux-src/d.tar.gz
	./scripts/target-scpsh 'rm -rfd ../target_prefix/linux-src && mkdir -p ../target_prefix/linux-src'
	./scripts/target-scpsh -C $(dir $<) 'tar xf d.tar.gz --directory=../target_prefix/linux-src'
	touch $@

.build/target-state/$(T)/linux-tools: .build/target-state/$(T)/linux-src
	./scripts/target-scpsh 'sudo apt-get --assume-yes install make gcc binutils-dev libreadline-dev libbison-dev flex libelf-dev'
	./scripts/target-scpsh 'sudo make -C ../target_prefix/linux-src/tools bpf_install'
	touch $@

# Could also be installed from ../target_prefix/linux-src on target, but this
# was copied from AnyCall and works.
#
# Installs custom-kernel's perf as perf_$(uname -r) to dist. it from the systems
# regular perf. To be used by bench-scripts.
.build/target-state/$(T)/linux-perf: $(LINUX_PERF_TARXZ)
	./scripts/target-scpsh 'rm -rfd ../target_prefix/linux-perf'
	./scripts/target-scpsh 'mkdir -p ../target_prefix/linux-perf'
	./scripts/target-scpsh -C $(dir $(LINUX_PERF_TARXZ)) 'tar xf linux-perf.tar.xz -C ../target_prefix/linux-perf'
	./scripts/target-scpsh 'sudo apt-get install --yes flex bison'
	./scripts/target-scpsh 'make -j $$(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-perf/perf*/tools/perf'
	./scripts/target-scpsh 'sudo ln -sf ../target_prefix/linux-perf/perf*/tools/perf/perf /usr/local/bin/perf_$$(uname -r)'
	touch $@

# Expected to fail if booted qemu runs outdated kernel.
.run/debian.ssh_port: $(LINUX_TREE)
	T=qemu-debian ./scripts/target-scpsh 'systemctl poweroff' && echo "boot qemu with new kernel!" && exit 1

.build/target-state/qemu-debian/kernel: .run/debian.ssh_port
	touch $@

#
# BPF Samples
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
