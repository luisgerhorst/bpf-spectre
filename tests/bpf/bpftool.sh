#!/bin/bash
set -uo pipefail
set -x

obj="$1"
capsh_args="$2"

cs="capsh $capsh_args -- -c"

uname -a
pwd
bpftool --version
$cs 'capsh --print'

path=/sys/fs/bpf/$(basename $obj .bpf.o)
$cs "bpftool prog loadall $obj $path" 2> ../result_dir/loadall.log
exitcode=$?
echo $exitcode > ../result_dir/loadall.bpftool-guess.exitcode
echo "NA" > ../result_dir/loadall.inferred-type
if [ $exitcode != "0" ]
then
    # Types supported by bpftool v7.0.0, libbpf v1.0
    for type in socket sk_reuseport/migrate sk_reuseport kprobe+ uprobe+ uprobe.s+ kretprobe+ uretprobe+ uretprobe.s+ kprobe.multi+ kretprobe.multi+ ksyscall+ kretsyscall+ usdt+ tc classifier action tracepoint+ tp+ raw_tracepoint+ raw_tp+ raw_tracepoint.w+ raw_tp.w+ tp_btf+ fentry+ fmod_ret+ fexit+ fentry.s+ fmod_ret.s+ fexit.s+ freplace+ lsm+ lsm.s+ lsm_cgroup+ iter+ iter.s+ syscall xdp.frags/devmap xdp/devmap xdp.frags/cpumap xdp/cpumap xdp.frags xdp perf_event lwt_in lwt_out lwt_xmit lwt_seg6local sockops sk_skb/stream_parser sk_skb/stream_verdict sk_skb sk_msg lirc_mode2 flow_dissector cgroup_skb/ingress cgroup_skb/egress cgroup/skb cgroup/sock_create cgroup/sock_release cgroup/sock cgroup/post_bind4 cgroup/post_bind6 cgroup/bind4 cgroup/bind6 cgroup/connect4 cgroup/connect6 cgroup/sendmsg4 cgroup/sendmsg6 cgroup/recvmsg4 cgroup/recvmsg6 cgroup/getpeername4 cgroup/getpeername6 cgroup/getsockname4 cgroup/getsockname6 cgroup/sysctl cgroup/getsockopt cgroup/setsockopt cgroup/dev struct_ops+ sk_lookup
    do
        type_path=$(echo $type | tr '/+.' "___")
        $cs "bpftool prog loadall $obj $path type $type" 2>> ../result_dir/loadall.type.$type_path.log
        exitcode=$?
        echo $exitcode > ../result_dir/loadall.$type_path.exitcode
        if [ $exitcode == "0" ]
        then
            echo $type > ../result_dir/loadall.inferred-type
            break
        fi
    done
fi
echo $exitcode > ../result_dir/loadall.exitcode

shopt -s nullglob
for prog in "$path"/*
do
    bpftool prog dump xlated pinned "$prog" > ../result_dir/xlated.$(basename $prog)
    bpftool prog dump jited pinned "$prog" > ../result_dir/jited.$(basename $prog)
done

rm -rfd $path
