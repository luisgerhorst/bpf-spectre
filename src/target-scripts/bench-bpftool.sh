#!/bin/bash
{
	set -euo pipefail
	set -x

	dst="$1"
	burst_len=$2

	values_dst=${dst}/values
	bpftool_dst=${dst}/bpftool
	mkdir -p ${dst}/values ${bpftool_dst}

	obj="$OSE_BPF_OBJ"
	capsh_args="$OSE_CAPSH_ARGS"
	OSE_BPFTOOL="${OSE_BPFTOOL:-./bpftool-v5.18}"
	OSE_BPFTOOL_TYPE="${OSE_BPFTOOL_TYPE:-}"
	if [ "$OSE_BPFTOOL_TYPE" == "" ]
	then
		# Types supported by bpftool v7.0.0, libbpf v1.0
		OSE_BPFTOOL_TYPE="socket sk_reuseport/migrate sk_reuseport kprobe+ uprobe+ uprobe.s+ kretprobe+ uretprobe+ uretprobe.s+ kprobe.multi+ kretprobe.multi+ ksyscall+ kretsyscall+ usdt+ tc classifier action tracepoint+ tp+ raw_tracepoint+ raw_tp+ raw_tracepoint.w+ raw_tp.w+ tp_btf+ fentry+ fmod_ret+ fexit+ fentry.s+ fmod_ret.s+ fexit.s+ freplace+ lsm+ lsm.s+ lsm_cgroup+ iter+ iter.s+ syscall xdp.frags/devmap xdp/devmap xdp.frags/cpumap xdp/cpumap xdp.frags xdp perf_event lwt_in lwt_out lwt_xmit lwt_seg6local sockops sk_skb/stream_parser sk_skb/stream_verdict sk_skb sk_msg lirc_mode2 flow_dissector cgroup_skb/ingress cgroup_skb/egress cgroup/skb cgroup/sock_create cgroup/sock_release cgroup/sock cgroup/post_bind4 cgroup/post_bind6 cgroup/bind4 cgroup/bind6 cgroup/connect4 cgroup/connect6 cgroup/sendmsg4 cgroup/sendmsg6 cgroup/recvmsg4 cgroup/recvmsg6 cgroup/getpeername4 cgroup/getpeername6 cgroup/getsockname4 cgroup/getsockname6 cgroup/sysctl cgroup/getsockopt cgroup/setsockopt cgroup/dev struct_ops+ sk_lookup"
	fi

	cs="sudo capsh $capsh_args -- -c"

	sudo --non-interactive $OSE_BPFTOOL --version > ${values_dst}/bpftool_version &
	$cs 'capsh --print' > ${dst}/capsh-print &
	mkdir ${bpftool_dst}/loadall_type &

	path=/sys/fs/bpf/$(basename $obj .bpf.o)
	# Clean up leftovers from failed previous runs.
	sudo rm -rfd $path &

	# sudo $OSE_BPFTOOL --bpffs > ${bpftool_dst}/bpffs-init

	# Must happen before load for bpf sysctls.
	./bench-runtime-begin.sh $@ &

	wait

	# Heuristic: Assume the longest log is the most interesting.
	exitcode=NA
	largest_log_size=0
	set +x
	for type in $OSE_BPFTOOL_TYPE
	do
		type_path=$(echo $type | tr '/+.' "___")

		echo -n " $type:" 1>&2
		set +e
		$cs "$OSE_BPFTOOL --debug prog loadall $obj $path type $type" \
			2> ${bpftool_dst}/loadall_type/$type_path.log
		type_exitcode=$?
		set -e
		log_size=$(wc --bytes ${bpftool_dst}/loadall_type/$type_path.log | cut --delimiter=' ' --field=1)
		echo -n "$type_exitcode" 1>&2

		echo -n $type_exitcode > ${bpftool_dst}/loadall_type/$type_path.exitcode

		if [ $type_exitcode == "0" ]
		then
			exitcode=$type_exitcode
			echo -n loadall_type/$type_path > ${values_dst}/bpftool_loadall_path
			echo -n $type > ${values_dst}/bpftool_loadall_type
			break
		fi

		if [ $log_size -ge $largest_log_size ]
		then
			echo -n ",${log_size}B" 1>&2
			exitcode=$type_exitcode
			largest_log_size=$log_size
			echo -n loadall_type/$type_path > ${values_dst}/bpftool_loadall_path
			echo -n $type > ${values_dst}/bpftool_loadall_type
			set +x
		fi
	done
	set -x

	echo -n $exitcode > ${values_dst}/bpftool_loadall_exitcode

	if [ $exitcode != "0" ]
	then
		./bench-runtime-end.sh $@
		exit 0
	fi

	IFS=$'\n'
	for prog in $(sudo find "$path" -type f)
	do
		sudo $OSE_BPFTOOL prog dump xlated pinned "$prog" > ${bpftool_dst}/xlated.$(basename $prog) &
		sudo $OSE_BPFTOOL prog dump jited pinned "$prog" > ${bpftool_dst}/jited.$(basename $prog) &
		sudo $OSE_BPFTOOL --json --pretty prog dump xlated pinned "$prog" > ${bpftool_dst}/xlated.$(basename $prog).json &
		sudo $OSE_BPFTOOL --json --pretty prog dump jited pinned "$prog" > ${bpftool_dst}/jited.$(basename $prog).json &
		# sudo bpftool --json prog dump jited pinned "$prog" opcodes > ${bpftool_dst}/jited-opcodes.$(basename $prog)
		# sudo bpftool prog dump jited pinned "$prog" linum > ${bpftool_dst}/jited-linum.$(basename $prog)
	done
	unset IFS

	wait

	# TODO: $OSE_BPFTOOL prog profile PROG [duration DURATION] METRICs

	kvm=$(lscpu | grep 'KVM' > /dev/null; echo $?)

	IFS=$'\n'
	for prog in $(sudo find "$path" -type f)
	do
		ec=unused

		if [ "$kvm" = "1" ]
		then
			sync
			echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
			sleep 1
		fi
		for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
		do

			set +e
			# Keyword repeat is used to indicate the number of consecutive runs to perform.
			# Note that output data and context printed to files correspond to the last of
			# those runs. The duration printed out at the end of the runs is an average over
			# all runs performed by the command.
			#
			# 32b garbage to be put into xdp_md.data for section(xdp) programs:
			echo -n "01234567012345670123456701234567" \
				| sudo $OSE_BPFTOOL --json --pretty prog run pinned "$prog" data_in - repeat $(expr $burst_pos + 1) \
				> ${bpftool_dst}/run.$(basename $prog).$burst_pos.json
			ec=$?
			set -e

			if [ $ec != 0 ]
			then
				break
			fi
		done

		echo -n $ec > ${values_dst}/bpftool_run_exitcode.$(basename $prog)

		echo -n "$ec " >> ${values_dst}/bpftool_run_exitcodes
		echo -n "$(basename $prog) " >> ${values_dst}/bpftool_progs
	done
	unset IFS

	./bench-runtime-end.sh $@ &
	sudo rm -rfd $path &
	wait

	exit
}
