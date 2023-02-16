# Libbpf Bootstrap Examples
LBE_APPS = minimal minimal_legacy bootstrap uprobe kprobe fentry usdt sockfilter tc

# Cilium
#
# List from cilium bpf/init.sh:
CILIUM_C = $(PREFIX)/external/cilium/bpf/bpf_sock.c
# Has legacy map:
# $(PREFIX)/external/cilium/bpf/bpf_alignchecker.c
#
# Does not load:
# $(PREFIX)/external/cilium/bpf/bpf_overlay.c
#
#
CILIUM_S = $(patsubst $(PREFIX)/external/cilium/bpf/bpf_%.c,$(PREFIX)/prog/cilium_%.bpf.s,$(CILIUM_C))

# vbpf
VBPF_C = $(wildcard $(PREFIX)/external/vbpf/src/*.c)
VBPF_S = $(patsubst $(PREFIX)/external/vbpf/src/%.c,$(PREFIX)/prog/vbpf_%.bpf.s,$(VBPF_C))

ALL_S = $(wildcard $(PREFIX)/prog/custom_*.bpf.s) \
	$(VBPF_S) \
	$(CILIUM_S) \
	$(patsubst %,$(PREFIX)/prog/lbe_%.bpf.s,$(LBE_APPS))
