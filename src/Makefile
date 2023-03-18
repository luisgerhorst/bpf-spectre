include env.mk

LINUX_MAIN ?= linux-main

.PHONY: all
all: release-all

.PHONY: target
target: release-target

.PHONY: release-%
release-%: configure .build/deps
	$(MAKE) -f release.mk $*

#
# Configure
#

.PHONY: configure
configure: | .build
	./scripts/configure.sh
	$(MAKE) -C linux-main headers_install

linux%/.config: configure

.PHONY: linux-%config
linux-%config: $(LINUX_MAIN)/.config
	$(MAKE) -C $(LINUX_MAIN) $*config
	$(MAKE) -C $(LINUX_MAIN) savedefconfig
	cp $(LINUX_MAIN)/defconfig $(CONFIG)
	cp $(LINUX_MAIN)/.config $(CONFIG).config

#
# kselftest
#

.PHONY: kselftest
# TODO: Add llvm-15 on target to deps.
kselftest: target
	./scripts/target-scpsh 'PATH=/usr/lib/llvm-15/bin:$$PATH $(MAKE) -C ../target_prefix/linux-src SKIP_TARGETS=alsa TARGETS=bpf -j $$(nproc) all kselftest-all'
	./scripts/target-scpsh 'PATH=/usr/lib/llvm-15/bin:$$PATH $(MAKE) -C ../target_prefix/linux-src SKIP_TARGETS=alsa TARGETS=bpf kselftest'

#
# etc
#

.PHONY: clean
clean:
	$(MAKE) -C bpf-samples clean
	$(MAKE) -C linux mrproper
	$(MAKE) -C linux-main mrproper
	rm -rfd .build .run

.PHONY: install-deps
install-deps: .build/deps

.build/deps: | .build
	sudo --non-interactive apt install autossh dwarves golang
	rm -f .build/llvm.sh # https://apt.llvm.org/
	env -C .build wget https://apt.llvm.org/llvm.sh
	chmod +x .build/llvm.sh
	sudo --non-interactive ./.build/llvm.sh 15 all
	make -C linux-main headers_install # for linux/samples/bpf
	touch $@

.build:
	mkdir $@
