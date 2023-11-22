#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
set -x

dst=$1
burst_len=$2

bpftool_dst=${dst}/bpftool
mkdir -p $dst/values $dst/log $dst/workload $bpftool_dst

. ./common.sh
loxilb_workflow=tcpsctpperf # tcplb #

# Kill processes from previous runs that did not properly terminate.
rmconfig() {
	set +e
	env -C $loxilb_src/cicd/$loxilb_workflow ./rmconfig.sh
	sudo pkill iperf
	sudo pkill iperf3
	set -e
}

rmconfig
uname -a
docker ps --all
ip netns list
env -C $loxilb_src/cicd/$loxilb_workflow ./config.sh

./bench-runtime-begin.sh $@

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	sudo bpftool prog show --json --pretty > $dst/workload/${burst_pos}.init.bpftool_prog_show.json 2>&1

	set +e
	$loxilb_src/cicd/$loxilb_workflow/validation-iperf $(nproc) 10 $dst/workload/$burst_pos.iperf- \
		&& $loxilb_src/cicd/$loxilb_workflow/validation-iperf3 $(nproc) 10 $dst/workload/$burst_pos.iperf3-
	exitcode=$?
	set -e

	sudo bpftool prog show --json --pretty > $dst/workload/${burst_pos}.bpftool_prog_show.json 2>&1
	sudo bpftool prog show > $dst/workload/${burst_pos}.bpftool_prog_show 2>&1

	echo -n "" > ${dst}/values/bpftool_progs
	set +x
	IFS=$'\n'
	for	line in $(cat $dst/workload/${burst_pos}.bpftool_prog_show.json)
	do
		if [[ $(echo "$line" | cut -d '"' -f 2) == "id" ]]
		then
			# Program ID:
			prog=$(echo "$line" | cut -d ':' -f 2 | cut -d , -f 1 | cut -d ' ' -f 2)
			echo "prog=$prog" 1>&2

			set +e
			sudo bpftool prog dump xlated id "$prog" > ${bpftool_dst}/xlated.$prog &
			p0=$!
			sudo bpftool prog dump jited id "$prog" > ${bpftool_dst}/jited.$prog &
			p1=$!
			sudo bpftool --json --pretty prog dump xlated id "$prog" > ${bpftool_dst}/xlated.$prog.json &
			p2=$!
			sudo bpftool --json --pretty prog dump jited id "$prog" > ${bpftool_dst}/jited.$prog.json &
			p3=$!
			wait $p0
			e0=$?
			wait $p1
			e1=$?
			wait $p2
			e2=$?
			wait $p3
			e3=$?
			set -e

			if [ $e0 = 0 ] && [ $e1 = 0 ] && [ $e2 = 0 ] && [ $e3 = 0 ]
			then
				echo -n " $prog" >> ${dst}/values/bpftool_progs
			fi
		fi
	done
	unset IFS
	set -x

	if [ $exitcode != 0 ]
	then
		break
	fi
done

docker exec -i llb1 bash -c 'cat /var/log/loxilb*.log' > $dst/log/llb1-loxilb.log

./bench-runtime-end.sh $@

rmconfig

echo -n $exitcode > ${dst}/values/workload_exitcode
