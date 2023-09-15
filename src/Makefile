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

.PHONY: linux-%/.config
linux-%/.config: configure

.PHONY: linux-menuconfig
linux-menuconfig: configure
	$(MAKE) -C $(LINUX_MAIN) menuconfig
	$(MAKE) -C $(LINUX_MAIN) kselftest-merge
	$(MAKE) -C $(LINUX_MAIN) savedefconfig
	cp $(LINUX_MAIN)/defconfig $(CONFIG)
	cp $(LINUX_MAIN)/.config $(CONFIG).config

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
	sudo ./.build/llvm.sh 16 all
	make -C linux-main headers_install # for linux/samples/bpf
	cd .build && curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb && sudo dpkg -i minikube_latest_amd64.deb
	touch $@

.build:
	mkdir -p $@
