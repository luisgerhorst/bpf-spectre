PREFIX = .
include prog.mk

# Don't remove intermediate results.
.SECONDARY:

.PHONY: all
all: dump

.PHONY: dump
dump: $(patsubst prog/%.bpf.s,.build/%.bpf.objdump,$(ALL_S)) \
	$(patsubst prog/%.bpf.s,.build/%.bpf.readelf,$(ALL_S))

.PHONY: prog/lbe_%.bpf.s
prog/lbe_%.bpf.s: | prog
	$(MAKE) -C external/libbpf-bootstrap/examples/c .output/$*.bpf.s
	ln -fs ../external/libbpf-bootstrap/examples/c/.output/$*.bpf.s $@

# BUG: These currently do not load. Some tail-call map is missing.
.PHONY: prog/cilium_%.bpf.s
prog/cilium_%.bpf.s: Makefile | prog
	$(MAKE) -C external/cilium/bpf bpf_$*.s
	ln -fs ../external/cilium/bpf/bpf_$*.s $@

CLANG ?= clang
ARCH := $(shell uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/' | sed 's/ppc64le/powerpc/' | sed 's/mips.*/mips/')
#
# Get Clang's default includes on this system. We'll explicitly add these dirs
# to the includes list when compiling with `-target bpf` because otherwise some
# architecture-specific dirs will be "missing" on some architectures/distros -
# headers such as asm/types.h, asm/byteorder.h, asm/socket.h, asm/sockios.h,
# sys/cdefs.h etc. might be missing.
#
# Use '-idirafter': Don't interfere with include mechanics except where the
# build would have failed anyways.
CLANG_BPF_SYS_INCLUDES = $(shell $(CLANG) -v -E - </dev/null 2>&1 \
	| sed -n '/<...> search starts here:/,/End of search list./{ s| \(/.*\)|-idirafter \1|p }')
prog/vbpf_%.bpf.s: external/vbpf/src/%.c | prog
	$(CLANG) -g -O2 -target bpf -D__TARGET_ARCH_$(ARCH) $(CLANG_BPF_SYS_INCLUDES) -c $(filter %.c,$^) -S -o $@

# https://pchaigno.github.io/bpf/2021/10/20/ebpf-instruction-sets.html
.build/%.bpf.o: prog/%.bpf.s | .build
	llvm-mc -triple bpf -mcpu=v3 -filetype=obj -o $@ $<

.build/%.bpf.objdump: .build/%.bpf.o | .build
	llvm-objdump -d $< > $@

.build/%.bpf.readelf: .build/%.bpf.o | .build
	llvm-readelf --all $< > $@

.build/%.bpftool.input: .build/%.bpf.o bpftool.sh
	rm -rfd $@ && mkdir -p $@ && cp -f $^ $@/

# TODO
CIAOPATH=spectector-modules
SPECTECTOR=$(CIAOPATH)/build/bin/spectector

$(SPECTECTOR): $(wildcard $(CIAOPATH)/spectector/src/*.pl) $(wildcard $(CIAOPATH)/muasm_translator/src/*.pl)
	CIAOPATH=$(CIAOPATH) ciao build -r spectector

.build/%.spectector.log: prog/%.bpf.s $(SPECTECTOR) | .build
	perf stat --output .build/$*.perf -x , -e duration_time -e task-clock $(SPECTECTOR) $< 2>&1 | tee $@

.PHONY: clean
clean:
	rm -f prog/lbe_*.bpf.s
	rm -f prog/cilium_*.bpf.s
	rm -f prog/vbpf_*.bpf.s
	rm -f prog/bcc_*.bpf.s
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
