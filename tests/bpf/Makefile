# Libbpf Bootstrap Examples
LBE_APPS = minimal minimal_legacy bootstrap uprobe kprobe fentry usdt sockfilter tc

# Cilium
CILIUM_C = $(wildcard cilium/bpf/bpf_*.c)
CILIUM_S = $(patsubst cilium/bpf/bpf_%.c,cilium_%.bpf.s,$(CILIUM_C))

# May contain duplicates.
ALL_S = $(wildcard *.bpf.s) $(CILIUM_S) $(patsubst %,lbe_%.bpf.s,$(LBE_APPS))

# Don't remove intermediate results.
.SECONDARY:

.PHONY: all
all: dumps .build/test-results.tsv.gz

.PHONY: dump
dump: $(patsubst %.bpf.s,.build/%.bpf.objdump,$(ALL_S)) \
	$(patsubst %.bpf.s,.build/%.bpf.readelf,$(ALL_S)) \
	$(patsubst %.bpf.s,.build/%.xlated,$(ALL_S))

.PHONY: lbe_%.bpf.s
lbe_%.bpf.s:
	$(MAKE) -C libbpf-bootstrap/examples/c .output/$*.bpf.s
	ln -fs libbpf-bootstrap/examples/c/.output/$*.bpf.s $@

.PHONY: cilium_%.bpf.s
cilium_%.bpf.s:
	$(MAKE) -C cilium/bpf bpf_$*.s
	ln -fs cilium/bpf/bpf_$*.s $@

.build/%.bpf.o: %.bpf.s | .build
	llvm-mc -triple bpf -filetype=obj -o $@ $<

.build/%.bpf.objdump: .build/%.bpf.o | .build
	llvm-objdump -d $< > $@

.build/%.bpf.readelf: .build/%.bpf.o | .build
	llvm-readelf --all $< > $@

/sys/fs/bpf/spectector-bpf/%: .build/%.bpf.o Makefile
	sudo rm -rfd $@
	sudo bpftool prog loadall $< $@ 2>&1 > .build/$*.loadall

.build/%.xlated: /sys/fs/bpf/spectector-bpf/%
	sudo ./bpftool-dumpall $< 2>&1 > $@

# .build/%.dump-jited: /sys/fs/bpf/spectector-bpf/%
# 	sudo bpftool prog dump jited pinned $< > $@

CIAOPATH=$(abspath ../../..)
SPECTECTOR=$(CIAOPATH)/build/bin/spectector

.PHONY: $(SPECTECTOR)
$(SPECTECTOR):
	CIAOPATH=$(CIAOPATH) ciao build -r spectector

.build/%.spectector.log: %.bpf.s $(SPECTECTOR) | .build
	perf stat --output .build/$*.perf -x , -e duration_time -e task-clock $(SPECTECTOR) $< 2>&1 | tee $@

.build/%.test-result.yaml: .build/%.spectector.log %.bpf.s
	./summarize-test-result.py $@ $< $*.bpf.s .build/$*.perf

.build/test-results.tsv.gz: $(patsubst %.bpf.s,.build/%.test-result.yaml,$(ALL_S))
	./join-yamls.py --output $@ --yamls $^

.build:
	mkdir -p $@

.PHONY: get-pwned
get-pwned:
	echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid
	# sudo setcap cap_bpf+ep $(shell which bpftool)
	sudo mkdir /sys/fs/bpf/spectector-bpf
	sudo chgrp $(USER) /sys/fs/bpf/spectector-bpf
	sudo chmod g+rwx /sys/fs/bpf/spectector-bpf

.PHONY: lock-system
lock-system:
	echo "4" | sudo tee /proc/sys/kernel/perf_event_paranoid
	# sudo setcap -r $(shell which bpftool)
	sudo rm -rfd /sys/fs/bpf/spectector-bpf/

.PHONY: install-deps
install-deps:
	sudo apt install golang llvm python3-pandas

.PHONY: clean
clean:
	rm -f lbe_*.bpf.s
	rm -f cilium_*.bpf.s
	rm -rfd .build
	sudo rm -rfd /sys/fs/bpf/spectector-bpf/*
