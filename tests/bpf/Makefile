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
all: $(patsubst %.bpf.s,.build/%.bpf.objdump,$(ALL_S)) \
	$(patsubst %.bpf.s,.build/%.bpf.readelf,$(ALL_S)) \
	.build/test-results.tsv.gz

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

CIAOPATH=../../..
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

.PHONY: allow-perf
allow-perf:
	echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid

.PHONY: install-deps
install-deps:
	sudo apt install golang llvm python3-pandas

.PHONY: clean
clean:
	rm -f lbe_*.bpf.s
	rm -f cilium_*.bpf.s
	rm -rfd .build
