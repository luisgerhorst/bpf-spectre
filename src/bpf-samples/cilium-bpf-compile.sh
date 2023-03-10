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
	      $EXTRA_OPTS					\
	      -c $LIB/$IN -o - |				\
	llc -march=bpf -mcpu=$MCPU -mattr=dwarfris -filetype=$TYPE -o $OUT
}


# TODO: Add more options from cilium bpf/Makefile?
MAX_BASE_OPTIONS="-DSKIP_DEBUG=1 -DENABLE_IPV4=1 -DENABLE_IPV6=1 -DENABLE_SOCKET_LB_TCP=1 -DENABLE_SOCKET_LB_UDP=1 -DENABLE_ROUTING=1 -DNO_REDIRECT=1 -DPOLICY_VERDICT_NOTIFY=1 -DALLOW_ICMP_FRAG_NEEDED=1 -DENABLE_IDENTITY_MARK=1 -DMONITOR_AGGREGATION=3 -DCT_REPORT_FLAGS=0x0002 -DENABLE_HOST_FIREWALL=1 -DENABLE_ICMP_RULE=1 -DENABLE_CUSTOM_CALLS=1"

pushd $1
bpf_compile $2.c $2.o obj "$MAX_BASE_OPTIONS"
