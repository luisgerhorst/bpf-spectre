# Libbpf Bootstrap Examples
LBE_APPS = minimal minimal_legacy bootstrap uprobe kprobe fentry usdt sockfilter tc

# Cilium
CILIUM_C = $(wildcard cilium/bpf/bpf_*.c)
CILIUM_S = $(patsubst cilium/bpf/bpf_%.c,prog/cilium_%.bpf.s,$(CILIUM_C))

# May contain duplicates.
ALL_S = $(wildcard prog/*.bpf.s) $(CILIUM_S) $(patsubst %,prog/lbe_%.bpf.s,$(LBE_APPS))

# Don't remove intermediate results.
.SECONDARY:

.PHONY: all
all: dump .build/test-results.tsv.gz

.PHONY: dump
dump: $(patsubst prog/%.bpf.s,.build/%.bpf.objdump,$(ALL_S)) \
	$(patsubst prog/%.bpf.s,.build/%.bpf.readelf,$(ALL_S)) \
	$(patsubst prog/%.bpf.s,.build/%.bpftool,$(ALL_S))

.PHONY: prog/lbe_%.bpf.s
prog/lbe_%.bpf.s: | prog
	$(MAKE) -C libbpf-bootstrap/examples/c .output/$*.bpf.s
	ln -fs ../libbpf-bootstrap/examples/c/.output/$*.bpf.s $@

.PHONY: prog/cilium_%.bpf.s
prog/cilium_%.bpf.s: | prog
	$(MAKE) -C cilium/bpf bpf_$*.s
	ln -fs ../cilium/bpf/bpf_$*.s $@

# https://pchaigno.github.io/bpf/2021/10/20/ebpf-instruction-sets.html
.build/%.bpf.o: prog/%.bpf.s | .build
	llvm-mc -triple bpf -mcpu=v3 -filetype=obj -o $@ $<

.build/%.bpf.objdump: .build/%.bpf.o | .build
	llvm-objdump -d $< > $@

.build/%.bpf.readelf: .build/%.bpf.o | .build
	llvm-readelf --all $< > $@

.build/%.bpftool.input: .build/%.bpf.o bpftool.sh
	rm -rfd $@ && mkdir -p $@ && cp -f $^ $@/

.build/%.bpftool: .build/%.bpftool.input
	rm -rfd $@
	env -C linux-build ./scripts/target-scpsh -C ../$< -o ../$@ './bpftool.sh $*.bpf.o 2>&1 | tee ../result_dir/log'

CIAOPATH=$(abspath ../../..)
SPECTECTOR=$(CIAOPATH)/build/bin/spectector

$(SPECTECTOR): $(wildcard $(CIAOPATH)/spectector/src/*.pl) $(wildcard $(CIAOPATH)/muasm_translator/src/*.pl)
	CIAOPATH=$(CIAOPATH) ciao build -r spectector

.build/%.spectector.log: prog/%.bpf.s $(SPECTECTOR) | .build
	perf stat --output .build/$*.perf -x , -e duration_time -e task-clock $(SPECTECTOR) $< 2>&1 | tee $@

.build/%.test-result.yaml: .build/%.spectector.log
	./summarize-test-result.py $@ $^ prog/$*.bpf.s .build/$*.perf .build/$*.loadall.exit-code

.build/test-results.tsv.gz: $(patsubst prog/%.bpf.s,.build/%.test-result.yaml,$(ALL_S))
	./join-yamls.py --output $@ --yamls $^

.PHONY: clean
clean:
	rm -f prog/lbe_*.bpf.s
	rm -f prog/cilium_*.bpf.s
	rm -rfd .build

.PHONY: get-pwned
get-pwned:
	echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid

.PHONY: lock-system
lock-system:
	echo "4" | sudo tee /proc/sys/kernel/perf_event_paranoid

.PHONY: install-deps
install-deps:
	sudo apt install golang llvm python3-pandas

.build:
	mkdir -p $@

prog:
	mkdir -p $@
