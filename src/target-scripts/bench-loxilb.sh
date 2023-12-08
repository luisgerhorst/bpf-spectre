#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
set -x

dst=$1
burst_len=$2
perf_events=${OSE_PERF_EVENTS:-"-e instructions -e cycles -e branch-misses"}

bpftool_dst=${dst}/bpftool
mkdir -p $dst/values $dst/workload $bpftool_dst

. ./common.sh
OSE_LOXILB_WORKFLOW=${OSE_LOXILB_WORKFLOW:-tcpsctpperf}
OSE_LOXILB_VALIDATION=${OSE_LOXILB_VALIDATION:-iperf3-sctp}
OSE_LOXILB_CLIENTS=${OSE_LOXILB_CLIENTS:-1}
export OSE_LOXILB_SERVERS=${OSE_LOXILB_SERVERS:-1}

# It's important to note that wrk2 extends the initial calibration period to 10
# seconds (from wrk's 0.5 second), so runs shorter than 10-20 seconds may not
# present useful information.
OSE_LOXILB_TIME=${OSE_LOXILB_TIME:-30}

# Kill processes from previous runs that did not properly terminate.
rmconfig() {
	set +e
	env -C $loxilb_src/cicd/$OSE_LOXILB_WORKFLOW ./rmconfig.sh
	sudo pkill iperf
	sudo pkill iperf3
	set -e
}

rmconfig
uname -a
docker ps
ip netns list

./bench-runtime-begin.sh $@

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	# Save bpf programs loaded by system to filter them out in analysis.
	list_bpf_progs() {
		flags="$1"
		first_suffix="$2"

		last_suffix=""
		if [[ "$flags" == "--json" ]]
		then
			flags="--json --pretty"
			last_suffix=".json"
		fi
	
		sudo bpftool prog show $flags > $dst/workload/${burst_pos}${first_suffix}.bpftool_prog_show${last_suffix} 2>&1
	}

	dump_bpf_progs() {
		suffix=$1

		echo -n "" > ${dst}/values/bpftool_progs$suffix
		set +x
		IFS=$'\n'
		for	line in $(cat $dst/workload/${burst_pos}${suffix}.bpftool_prog_show.json)
		do
			if [[ $(echo "$line" | cut -d '"' -f 2) == "id" ]]
			then
				# Program ID:
				prog=$(echo "$line" | cut -d ':' -f 2 | cut -d , -f 1 | cut -d ' ' -f 2)
				echo "prog=$prog" 1>&2

				set +e
				sudo bpftool --json --pretty prog dump xlated id "$prog" > ${bpftool_dst}/xlated.${prog}${suffix}.json &
				p2=$!
				sudo bpftool --json --pretty prog dump jited id "$prog" > ${bpftool_dst}/jited.${prog}${suffix}.json &
				p3=$!
				wait $p2
				e2=$?
				wait $p3
				e3=$?
				set -e

				if [ $e2 = 0 ] && [ $e3 = 0 ]
				then
					echo -n " $prog" >> ${dst}/values/bpftool_progs${suffix}
				fi
			fi
		done
		unset IFS
		set -x
	}

	list_bpf_progs --json .init
	# dump_bpf_progs .init

	env -C $loxilb_src/cicd/$OSE_LOXILB_WORKFLOW ./config.sh

	# list_bpf_progs --json .before
	# dump_bpf_progs .before

	# set +x
	# new_progs=""
	# for before_prog in $(cat $dst/values/bpftool_progs.before)
	# do
	# 	is_new=true
	# 	for init_prog in $(cat $dst/values/bpftool_progs.init)
	# 	do
	# 		if [[ $init_prog == $before_prog ]]
	# 		then
	# 			is_new=false
	# 			break
	# 		fi
	# 	done
	# 	if [[ $is_new == true ]]
	# 	then
	# 		if [[ $new_progs == "" ]]
	# 		then
	# 			new_progs=$before_prog
	# 		else
	# 			new_progs=$new_progs,$before_prog
	# 		fi
	# 	fi
	# done
	# set -x

	# --pid=$(pidof /root/loxilb-io/loxilb/loxilb)
	set +e
	sudo --preserve-env perf stat \
		--output ${dst}/workload/${burst_pos}.perf -x , \
		--all-cpus \
		-e duration_time \
		-e task-clock \
		-e raw_syscalls:sys_enter \
		${perf_events} \
		$loxilb_src/cicd/$OSE_LOXILB_WORKFLOW/validation-${OSE_LOXILB_VALIDATION} \
		${OSE_LOXILB_CLIENTS} ${OSE_LOXILB_TIME} $dst/workload/$burst_pos.${OSE_LOXILB_VALIDATION}-
	exitcode=$?
	set -e

	list_bpf_progs --json ""
	dump_bpf_progs ""

	docker exec -i llb1 bash -c 'cat /var/log/loxilb*.log' > $dst/workload/${burst_pos}.llb1-loxilb.log

	env -C $loxilb_src/cicd/$OSE_LOXILB_WORKFLOW ./rmconfig.sh

	if [ $exitcode != 0 ]
	then
		break
	fi
done

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode

jobs -l
wait
