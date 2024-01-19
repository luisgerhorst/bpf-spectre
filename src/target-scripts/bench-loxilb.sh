#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
set -x

dst=$1
burst_len=$2

bpftool_dst=${dst}/bpftool
mkdir -p $dst/values $dst/workload $bpftool_dst

. ./common.sh
OSE_PERF_EVENTS=${OSE_PERF_EVENTS:-"-e instructions -e cycles -e branch-misses"}
OSE_LOXILB_WORKFLOW=${OSE_LOXILB_WORKFLOW:-tcpsctpperf}
OSE_LOXILB_VALIDATION=${OSE_LOXILB_VALIDATION:-iperf3-sctp}
OSE_LOXILB_CLIENTS=${OSE_LOXILB_CLIENTS:-1}
export OSE_LOXILB_SERVERS=${OSE_LOXILB_SERVERS:-1}

# If set to a number, increase the rate by this value until the desired rate
# decreases.
OSE_WRK_RATE=${OSE_WRK_RATE:-1000}
OSE_WRK_RATE_AUTO_STEP=${OSE_WRK_RATE_AUTO_STEP:-false}

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

./bench-runtime-begin.sh $@

max_rate=0 # wrk_auto_step
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

	env -C $loxilb_src/cicd/$OSE_LOXILB_WORKFLOW ./config.sh

	echo -n "$OSE_WRK_RATE" > $dst/workload/$burst_pos.OSE_WRK_RATE

	# --pid=$(pidof /root/loxilb-io/loxilb/loxilb)
	export OSE_PERF_STAT=" \
		sudo --preserve-env perf stat \
		--output ${dst}/workload/${burst_pos}.perf -x , \
		--all-cpus \
		-e duration_time \
		-e task-clock \
		${OSE_PERF_EVENTS} \
		"
	validation=" \
		$loxilb_src/cicd/$OSE_LOXILB_WORKFLOW/validation-${OSE_LOXILB_VALIDATION} \
		${OSE_LOXILB_CLIENTS} ${OSE_LOXILB_TIME} $dst/workload/$burst_pos.${OSE_LOXILB_VALIDATION}- \
		"
	set +e
	if [ "${OSE_LOXILB_VALIDATION}" == wrk ]
	then
		$validation
		exitcode=$?
	else
		$OSE_PERF_STAT $validation
		exitcode=$?
	fi
	set -e

	list_bpf_progs --json ""
	dump_bpf_progs ""

	docker exec -i llb1 bash -c 'cat /var/log/loxilb*.log' > $dst/workload/${burst_pos}.llb1-loxilb.log

	env -C $loxilb_src/cicd/$OSE_LOXILB_WORKFLOW ./rmconfig.sh

	if [ $exitcode != 0 ]
	then
		break
	fi

	if [ $OSE_WRK_RATE_AUTO_STEP != false ] && grep 'Requests/sec' $dst/workload/$burst_pos.wrk-latency.log
	then
		rate=$(grep 'Requests/sec' $dst/workload/$burst_pos.wrk-latency.log | cut -d' ' -f3 | cut -d. -f1)
		if (( rate > max_rate ))
		then
			max_rate=$rate
		fi

		if (( (rate * 100)/OSE_WRK_RATE < 95 ))
		then
			export OSE_WRK_RATE_AUTO_STEP=$(( OSE_WRK_RATE_AUTO_STEP/2 ))
			export OSE_WRK_RATE=$max_rate
			max_rate=0
		else
			export OSE_WRK_RATE=$((OSE_WRK_RATE + OSE_WRK_RATE_AUTO_STEP))
		fi
	fi
done

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode

jobs -l
wait
