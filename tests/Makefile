# Libbpf Bootstrap Examples
LBE_APPS = minimal minimal_legacy bootstrap uprobe kprobe fentry usdt sockfilter tc

.PHONY: all
all: $(patsubst %,lbe_%.bpf.s,$(LBE_APPS))

.PHONY: lbe_%.bpf.s
lbe_%.bpf.s:
	$(MAKE) -C libbpf-bootstrap/examples/c .output/$*.bpf.s
	ln -s libbpf-bootstrap/examples/c/.output/$*.bpf.s $@

.PHONY: clean
clean:
	rm -f lbe_*.bpf.s
