#!/usr/bin/env bash
set -euo pipefail
set -x

DIR=.
LIB=.
MCPU=v3
NR_CPUS=1

# From init.sh bpf_compile()
function bpf_compile()
{
	IN=$1
	OUT=$2
	TYPE=$3
	EXTRA_OPTS=$4

	clang -O2 -target bpf -std=gnu89 -nostdinc -emit-llvm	\
	      -g -Wall -Wextra -Werror -Wshadow			\
	      -Wno-address-of-packed-member			\
	      -Wno-unknown-warning-option			\
	      -Wno-gnu-variable-sized-type-not-at-end		\
	      -Wdeclaration-after-statement			\
	      -Wimplicit-int-conversion -Wenum-conversion	\
	      -I. -I$DIR -I$LIB -I$LIB/include			\
	      -D__NR_CPUS__=$NR_CPUS				\
	      -DENABLE_ARP_RESPONDER=1				\
	      $EXTRA_OPTS					\
	      -c $LIB/$IN -o - |				\
	llc -march=bpf -mcpu=$MCPU -mattr=dwarfris -filetype=$TYPE -o $OUT
}

pushd $1
bpf_compile $2.c $2.o obj ""
