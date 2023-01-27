#!/bin/bash
set -euo pipefail
set -x

dst="$1"
burst_len=$2

set +e
sudo systemctl status fai-boot.service > $dst/fai_status
sudo systemctl status run-fai.service >> $dst/fai_status
sudo systemctl status run-fai.timer >> $dst/fai_status
set -e

values_dst=${dst}/values
bpftool_dst=${dst}/bpftool
mkdir -p ${dst}/values ${bpftool_dst}

obj="$BPF_OBJ"
capsh_args="$CAPSH_ARGS"

cs="sudo capsh $capsh_args -- -c"

sudo bpftool --version > ${bpftool_dst}/version
$cs 'capsh --print' > ${dst}/capsh-print
mkdir ${bpftool_dst}/loadall_type

hostname --short > ${values_dst}/hostname_short

path=/sys/fs/bpf/$(basename $obj .bpf.o)

# Clean up leftovers from failed previous runs.
sudo rm -rfd $path
# sudo bpftool --bpffs > ${bpftool_dst}/bpffs-init

set +e
$cs "bpftool --debug prog loadall $obj $path" 2> ${bpftool_dst}/loadall.log
exitcode=$?
set -e
echo -n $exitcode > ${values_dst}/bpftool_loadall_type_inferred_exitcode

echo -n "NA" > ${values_dst}/bpftool_loadall_type
if [ $exitcode != "0" ]
then
	set +x
	# Types supported by bpftool v7.0.0, libbpf v1.0
	for type in socket sk_reuseport/migrate sk_reuseport kprobe+ uprobe+ uprobe.s+ kretprobe+ uretprobe+ uretprobe.s+ kprobe.multi+ kretprobe.multi+ ksyscall+ kretsyscall+ usdt+ tc classifier action tracepoint+ tp+ raw_tracepoint+ raw_tp+ raw_tracepoint.w+ raw_tp.w+ tp_btf+ fentry+ fmod_ret+ fexit+ fentry.s+ fmod_ret.s+ fexit.s+ freplace+ lsm+ lsm.s+ lsm_cgroup+ iter+ iter.s+ syscall xdp.frags/devmap xdp/devmap xdp.frags/cpumap xdp/cpumap xdp.frags xdp perf_event lwt_in lwt_out lwt_xmit lwt_seg6local sockops sk_skb/stream_parser sk_skb/stream_verdict sk_skb sk_msg lirc_mode2 flow_dissector cgroup_skb/ingress cgroup_skb/egress cgroup/skb cgroup/sock_create cgroup/sock_release cgroup/sock cgroup/post_bind4 cgroup/post_bind6 cgroup/bind4 cgroup/bind6 cgroup/connect4 cgroup/connect6 cgroup/sendmsg4 cgroup/sendmsg6 cgroup/recvmsg4 cgroup/recvmsg6 cgroup/getpeername4 cgroup/getpeername6 cgroup/getsockname4 cgroup/getsockname6 cgroup/sysctl cgroup/getsockopt cgroup/setsockopt cgroup/dev struct_ops+ sk_lookup
	do
		type_path=$(echo $type | tr '/+.' "___")

		set +e
		$cs "bpftool --debug prog loadall $obj $path type $type" \
			2>> ${bpftool_dst}/loadall_type/$type_path.log
		exitcode=$?
		set -e

		echo -n $exitcode > ${bpftool_dst}/loadall_type/$type_path.exitcode

		if [ $exitcode == "0" ]
		then
			echo -n $type > ${values_dst}/bpftool_loadall_type
			break
		fi
	done
	set -x
fi

# sudo bpftool --bpffs > ${bpftool_dst}/bpffs

echo -n $exitcode > ${values_dst}/bpftool_loadall_exitcode
if [ $exitcode != "0" ]
then
	exit 0
fi

IFS=$'\n'
for prog in $(sudo find "$path" -type f)
do
	sudo bpftool prog dump xlated pinned "$prog" > ${bpftool_dst}/xlated.$(basename $prog)
	sudo bpftool prog dump jited pinned "$prog" > ${bpftool_dst}/jited.$(basename $prog)
	sudo bpftool --json --pretty prog dump xlated pinned "$prog" > ${bpftool_dst}/xlated.$(basename $prog).json
	sudo bpftool --json --pretty prog dump jited pinned "$prog" > ${bpftool_dst}/jited.$(basename $prog).json
	# sudo bpftool --json prog dump jited pinned "$prog" opcodes > ${bpftool_dst}/jited-opcodes.$(basename $prog)
	# sudo bpftool prog dump jited pinned "$prog" linum > ${bpftool_dst}/jited-linum.$(basename $prog)
done
unset IFS

# TODO:
#
# ensure reproduceability (see bench-workload-perf)
#
# Keyword repeat is used to indicate the number of consecutive runs to perform.
# Note that output data and context printed to files correspond to the last of
# those runs. The duration printed out at the end of the runs is an average over
# all runs performed by the command.
#
# bpftool prog profile PROG [duration DURATION] METRICs
IFS=$'\n'
for prog in $(sudo find "$path" -type f)
do
	# TODO: bash loop for bursts, bpftool_repeat for repeat (== warmup)

	set +e
	# 32b garbage to be put into xdp_md.data for section(xdp) programs:
	echo -n "01234567012345670123456701234567" \
		| sudo bpftool --json --pretty prog run pinned "$prog" data_in - repeat $burst_len \
		> ${bpftool_dst}/run.$(basename $prog).json
	ec=$?
	set -e
	echo -n "$ec " >> ${values_dst}/bpftool_run_exitcodes
	echo -n "$(basename $prog) " >> ${values_dst}/bpftool_progs
	echo -n $ec > ${values_dst}/bpftool_run_exitcode.$(basename $prog)
done
unset IFS

sudo rm -rfd $path
