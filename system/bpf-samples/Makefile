PREFIX=.

# Libbpf Bootstrap Examples
LBE_APPS = minimal minimal_legacy bootstrap uprobe kprobe fentry usdt sockfilter tc
LBE = $(patsubst %,lbe_%,$(LBE_APPS))

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
CILIUM = $(patsubst $(PREFIX)/external/cilium/bpf/bpf_%.c,cilium_%,$(CILIUM_C))

# vbpf
VBPF_C = $(wildcard $(PREFIX)/external/vbpf/src/*.c)
VBPF = $(patsubst $(PREFIX)/external/vbpf/src/%.c,vbpf_%,$(VBPF_C))

CUSTOM_S = $(wildcard $(PREFIX)/prog/custom_*.bpf.s)
CUSTOM = $(patsubst $(PREFIX)/prog/%.bpf.s,%,$(CUSTOM_S))

KATRAN = $(patsubst %,katran_%,balancer_kern healthchecking_ipip healthchecking_kern xdp_pktcntr xdp_root)

LINUX=../linux

#  $(KATRAN)
PROGS = $(VBPF) $(CILIUM) $(LBE) $(CUSTOM) falco_probe

LLVM_BIN = /usr/lib/llvm-15/bin
ifneq ($(wildcard $(LLVM_BIN)/*),)
	export PATH := $(LLVM_BIN):$(PATH)
endif

# Don't remove intermediate results.
.SECONDARY:

.PHONY: all
all: $(patsubst %,prog-%,$(PROGS)) vbi linux-samples linux-selftests

.PHONY: vbi
vbi:
	./vbi.sh

.PHONY: linux-samples
linux-samples:
	$(MAKE) -C $(LINUX)/samples/bpf
	./linux-samples.sh

.PHONY: linux-selftests
linux-selftests:
	$(MAKE) -C $(LINUX) vmlinux
	env -i PATH=$(PATH) $(MAKE) -C $(LINUX)/tools/testing/selftests/bpf -k all > .build/make-linux-selftests.stdout 2> .build/make-linux-selftests.stderr || true
	./linux-selftests.sh

# .PHONY: prog-%
# prog-%:
# 	$(MAKE) .build/katran_$*.bpf.o .build/katran_$*.bpf.objdump .build/katran_$*.bpf.readelf

.PHONY: prog-%
prog-%:
	$(MAKE) .build/$*.bpf.o .build/$*.bpf.objdump .build/$*.bpf.readelf

#
# libbpf/examples
#

.PHONY: prog/lbe_%.bpf.s
prog/lbe_%.bpf.s: | prog
	$(MAKE) -C external/libbpf-bootstrap/examples/c .output/$*.bpf.s
	ln -fs ../external/libbpf-bootstrap/examples/c/.output/$*.bpf.s $@

#
# Katran
#

.PHONY: .build/katran_%.bpf.o
.build/katran_%.bpf.o: Makefile | .build
	env -C external/katran ./build.sh --num-jobs $(nproc)
	ln -fs ../external/katran/_build/deps/bpfprog/bpf/$*.o $@

#
# Cilium
#

.PHONY: prog/cilium_%.bpf.s
prog/cilium_%.bpf.s: Makefile | prog
	$(MAKE) -C external/cilium/bpf $(CILIUM_ARGS) bpf_$*.s
	ln -fs ../external/cilium/bpf/bpf_$*.s $@

.build/cilium_%.bpf.o: cilium-bpf-compile.sh Makefile | .build
	./cilium-bpf-compile.sh external/cilium/bpf bpf_$*
	ln -fs ../external/cilium/bpf/bpf_$*.o $@

#
# vbpf
#

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
#
prog/vbpf_%.bpf.s: external/vbpf/src/%.c | prog
	$(CLANG) -g -O2 -target bpf -D__TARGET_ARCH_$(ARCH) $(CLANG_BPF_SYS_INCLUDES) -c $(filter %.c,$^) -S -o $@

#
# vbpf Falco
#

.PHONY: .build/falco_%.bpf.o
.build/falco_%.bpf.o: external/vbpf/falco/probe.o | .build
	ln -fs ../$< $@

#
# generic
#

# https://pchaigno.github.io/bpf/2021/10/20/ebpf-instruction-sets.html
.build/%.bpf.o: prog/%.bpf.s | .build
	llvm-mc -triple bpf -mcpu=v3 -filetype=obj -o $@ $<

.build/%.bpf.objdump: .build/%.bpf.o | .build
	llvm-objdump -d $< > $@

.build/%.bpf.readelf: .build/%.bpf.o | .build
	llvm-readelf --all $< > $@

CIAOPATH=$(shell pwd)/spectector-proj
SPECTECTOR=$(CIAOPATH)/build/bin/spectector

$(SPECTECTOR): $(wildcard $(CIAOPATH)/spectector/src/*.pl) $(wildcard $(CIAOPATH)/muasm_translator/src/*.pl)
	env -C $(CIAOPATH) CIAOPATH=$(CIAOPATH) ciao build -r spectector

.build/%.spectector.log: prog/%.bpf.s $(SPECTECTOR) | .build
	perf stat --output .build/$*.perf -x , -e duration_time -e task-clock $(SPECTECTOR) $< 2>&1 | tee $@

.PHONY: clean
clean:
	$(MAKE) -C external/cilium/bpf clean
	rm -f prog/lbe_*.bpf.s
	rm -f prog/cilium_*.bpf.s
	rm -f prog/vbpf_*.bpf.s
	rm -f prog/bcc_*.bpf.s
	rm -rfd .build

.PHONY: mrproper
mrproper: clean
	echo "4" | sudo tee /proc/sys/kernel/perf_event_paranoid
	rm -f .perf_event_paranoid_-1

.PHONY: install-deps
install-deps: .perf_event_paranoid_-1
	sudo apt install golang llvm
	echo "On Debian Bullseye/Ubuntu Jammy, follow https://apt.llvm.org/ to install llvm-15" && false

.perf_event_paranoid_-1:
	echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid
	touch $@

.build:
	mkdir -p $@

prog:
	mkdir -p $@
