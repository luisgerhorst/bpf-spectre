# Libbpf Bootstrap Examples
LBE_APPS = minimal minimal_legacy bootstrap uprobe kprobe fentry usdt sockfilter tc

CUSTOM_APPS = spectre

.PHONY: all
all: $(patsubst %,lbe_%.bpf.s,$(LBE_APPS)) $(patsubst %,%.bpf.o,$(CUSTOM_APPS))

.PHONY: lbe_%.bpf.s
lbe_%.bpf.s:
	$(MAKE) -C libbpf-bootstrap/examples/c .output/$*.bpf.s
	ln -s libbpf-bootstrap/examples/c/.output/$*.bpf.s $@

%.bpf.o: %.bpf.s
	llvm-mc -triple bpf -filetype=obj -o $@ $<

.PHONY: clean
clean:
	rm -f lbe_*.bpf.s
