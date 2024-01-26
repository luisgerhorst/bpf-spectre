#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
# On the SuT: Benchmarks workload performance.

random_port() {
    # https://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port
    comm -23 <(seq 49152 65535 | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) \
        | shuf \
        | head -n 1
}

set -x

dst=$1
burst_len=$2

# TODO: Use OSE_

# Environment from suite definition:
. ./common.sh
export OSE_TRACER="${OSE_TRACER:-true}"
export OSE_WORKLOAD_PREPARE="${OSE_WORKLOAD_PREPARE:-true}"
export OSE_WORKLOAD_CLEANUP="${OSE_WORKLOAD_CLEANUP:-true}"

# Available to workload:
export OSE_RANDOM_PORT="$(random_port)"

bpftool_dst=${dst}/bpftool
mkdir -p $dst/workload $dst/values $bpftool_dst

./bench-runtime-begin.sh $@

# Kill tracers from previous runs that did not properly terminate.
set +x
IFS=$'\n'
for	pid in $(sudo bpftool prog show | grep pids | cut -d " " -f 2 | cut -d '(' -f 2 | cut -d ')' -f 1)
do
	if [ $pid != 1 ] # skip systemd
	then
		echo "sudo kill -SIGKILL $pid" 1>&2
		sudo kill -SIGKILL $pid || true
	fi
done
unset IFS
set -x

sudo pkill memcached || true

bash -c "export OSE_RANDOM_PORT='$OSE_RANDOM_PORT'; ${OSE_WORKLOAD_PREPARE}"

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	sudo bpftool prog show --json --pretty > $dst/workload/${burst_pos}.init.bpftool_prog_show.json 2>&1

	set +m # allow sigint to background process
	$OSE_TRACER > $dst/workload/${burst_pos}.trace 2>&1 &
	tracer_pid=$!
	set -m

	set +e
	env -i sudo --preserve-env perf stat \
		--output ${dst}/workload/${burst_pos}.perf -x , \
		--all-cpus \
		-e duration_time \
		-e task-clock \
		-e raw_syscalls:sys_enter \
		${OSE_PERF_EVENTS} \
		bash -c "export OSE_RANDOM_PORT='$OSE_RANDOM_PORT'; ${OSE_WORKLOAD}" \
		> ${dst}/workload/${burst_pos}.stdout \
		2> ${dst}/workload/${burst_pos}.stderr
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

	sudo kill -SIGINT $tracer_pid || true # might have terminated already
	sleep 5 && sudo kill -SIGKILL $tracer_pid || true

	set +e
	wait $tracer_pid
	tracer_ec=$?
	set -e

	if [ $exitcode != 0 ] || [ $tracer_ec != 0 ]
	then
		break
	fi
done

# Must run in same pwd as _PREPARE.
bash -c "export OSE_RANDOM_PORT='$OSE_RANDOM_PORT'; ${OSE_WORKLOAD_CLEANUP}"

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode
echo -n $tracer_ec > ${dst}/values/tracer_exitcode
