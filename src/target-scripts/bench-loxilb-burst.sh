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

list_bpf_progs() {
	flags="$1"
	first_suffix="$2"

	last_suffix=""
	if [[ "$flags" == "--json" ]]
	then
		flags="--json --pretty"
		last_suffix=".json"
	fi

	sudo bpftool prog show $flags > $dst/workload/${first_suffix}.bpftool_prog_show${last_suffix} 2>&1
}

dump_bpf_progs() {
	suffix="$1"

	echo -n "" > ${dst}/values/bpftool_progs.$suffix
	set +x
	IFS=$'\n'
	for	line in $(cat $dst/workload/${suffix}.bpftool_prog_show.json)
	do
		if [[ $(echo "$line" | cut -d '"' -f 2) == "id" ]]
		then
			# Program ID:
			prog=$(echo "$line" | cut -d ':' -f 2 | cut -d , -f 1 | cut -d ' ' -f 2)
			echo "prog=$prog" 1>&2

			set +e
			sudo bpftool --json --pretty prog dump xlated id "$prog" > ${bpftool_dst}/xlated.${prog}.${suffix}.json
			e1=$?
			sudo bpftool --json --pretty prog dump jited id "$prog" > ${bpftool_dst}/jited.${prog}.${suffix}.json
			e2=$?
			set -e

			# Dump may fail spuriously.
			if [ $e1 = 0 ] && [ $e2 = 0 ]
			then
				echo -n " $prog" >> ${dst}/values/bpftool_progs.${suffix}
			fi
		fi
	done
	unset IFS
	set -x
}

# Save bpf programs loaded by system to filter them out in analysis.
list_bpf_progs --json init

env -C $loxilb_src/cicd/$OSE_LOXILB_WORKFLOW ./config.sh

list_bpf_progs --json pre

# --output is supplied by validation-* script.
export OSE_PERF_STAT=" \
	sudo --preserve-env perf stat \
	-x , \
	--all-cpus \
	-e duration_time \
	-e task-clock \
	${OSE_PERF_EVENTS} \
	"
set +e
$loxilb_src/cicd/$OSE_LOXILB_WORKFLOW/validation-${OSE_LOXILB_VALIDATION} \
	${OSE_LOXILB_CLIENTS} ${OSE_LOXILB_TIME} $dst/workload/ $burst_len
exitcode=$?
set -e

list_bpf_progs --json post
dump_bpf_progs post

docker exec -i llb1 bash -c 'cat /var/log/loxilb*.log' > $dst/workload/llb1-loxilb.log

env -C $loxilb_src/cicd/$OSE_LOXILB_WORKFLOW ./rmconfig.sh

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode
