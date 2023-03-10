.PHONY: all
all: .build/deps
	./scripts/prepare.sh
	$(MAKE) -f target.mk all

.PHONY: clean
clean:
	$(MAKE) -C bpf-samples clean
	$(MAKE) -C linux clean
	rm -rfd .build .run

.PHONY: install-deps
install-deps: .build/deps

.build/deps: | .build
	sudo apt install autossh dwarves
	touch $@

.build:
	mkdir $@
