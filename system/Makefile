.PHONY: all
all: .build/deps
	./scripts/configure.sh
	$(MAKE) -f target.mk all

.PHONY: clean
clean:
	$(MAKE) -C bpf-samples clean
	$(MAKE) -C linux clean
	rm -rfd .build .run

.PHONY: install-deps
install-deps: .build/deps

.build/deps: Makefile | .build
	sudo apt install autossh dwarves golang
	rm -f .build/llvm.sh # https://apt.llvm.org/
	env -C .build wget https://apt.llvm.org/llvm.sh
	chmod +x .build/llvm.sh
	sudo ./.build/llvm.sh 15 all
	make -C linux-main headers_install # for linux/samples/bpf
	touch $@

.build:
	mkdir $@
