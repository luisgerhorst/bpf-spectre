include env.mk

LINUX_MAIN ?= linux-main

.PHONY: all
all: release-all

.PHONY: target
target: release-target

.PHONY: release-%
release-%: configure | .build/deps
	$(MAKE) -f release.mk $*

#
# Configure
#

.PHONY: configure
configure: | .build .build/deps
	./scripts/configure.sh
	$(MAKE) -C linux-main headers_install

linux-%/.config: configure

.PHONY: linux-%config
linux-%config: $(LINUX_MAIN)/.config
	$(MAKE) -C $(LINUX_MAIN) $*config
	$(MAKE) -C $(LINUX_MAIN) savedefconfig
	cp $(LINUX_MAIN)/defconfig $(CONFIG)
	cp $(LINUX_MAIN)/.config $(CONFIG).config

#
# kselftest
#

MAKE_KSELFTEST="PATH=/usr/lib/llvm-15/bin:/usr/local/sbin:$$PATH $(MAKE) -C ../target_prefix/linux-src SKIP_TARGETS=alsa TARGETS=bpf BPFTOOL=$$(which bpftool)"

.PHONY: kselftest
# TODO: Add llvm-15 on target to deps.
kselftest: target
	./scripts/target-scpsh '$(MAKE_KSELFTEST) -j $$(nproc) kselftest-all'
	./scripts/target-scpsh '$(MAKE_KSELFTEST) kselftest'

#
# etc
#

.PHONY: clean
clean:
	$(MAKE) -C bpf-samples clean
	$(MAKE) -C linux mrproper
	$(MAKE) -C linux-main mrproper
	rm -rfd .build $(XDG_RUNTIME_DIR)/$(PROJ_NAME)-target-state

.PHONY: install-deps
install-deps: | .build/deps

# gcc-multilib: https://github.com/xdp-project/xdp-tutorial/issues/44
.build/deps: | .build
	sudo apt install autossh dwarves golang gcc-multilib
	rm -f .build/llvm.sh # https://apt.llvm.org/
	env -C .build wget https://apt.llvm.org/llvm.sh
	chmod +x .build/llvm.sh
	# sudo ./.build/llvm.sh 15 all
	make -C linux-main headers_install # for linux/samples/bpf
	touch $@

.build:
	mkdir -p $@
