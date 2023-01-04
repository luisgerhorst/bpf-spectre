# Libbpf Bootstrap Examples
LBE_APPS = minimal minimal_legacy bootstrap uprobe kprobe fentry usdt sockfilter tc

# Cilium
CILIUM_C = $(wildcard $(PREFIX)/external/cilium/bpf/bpf_*.c)
CILIUM_S = $(patsubst $(PREFIX)/external/cilium/bpf/bpf_%.c,$(PREFIX)/prog/cilium_%.bpf.s,$(CILIUM_C))

# vbpf
VBPF_C = $(wildcard $(PREFIX)/external/vbpf/src/*.c)
VBPF_S = $(patsubst $(PREFIX)/external/vbpf/src/%.c,$(PREFIX)/prog/vbpf_%.bpf.s,$(VBPF_C))

# May contain duplicates.
ALL_S = $(wildcard $(PREFIX)/prog/*.bpf.s) $(VBPF_S) $(CILIUM_S) $(patsubst %,$(PREFIX)/prog/lbe_%.bpf.s,$(LBE_APPS))
