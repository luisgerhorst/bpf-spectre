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

list_workload_bpf_progs --json init

bash -c "export OSE_RANDOM_PORT='$OSE_RANDOM_PORT'; ${OSE_WORKLOAD_PREPARE}"

set +m # allow sigint to background process
$OSE_TRACER > $dst/workload/trace 2>&1 &
tracer_pid=$!
set -m

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1

list_workload_bpf_progs --json pre

for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	set +e
	env -i sudo --preserve-env perf stat \
		--output ${dst}/workload/${burst_pos}.perf -x , \
		--all-cpus \
		${OSE_PERF_DEFAULT_EVENTS} \
		${OSE_PERF_EVENTS} \
		bash -c "export OSE_RANDOM_PORT='$OSE_RANDOM_PORT'; ${OSE_WORKLOAD}" \
		> ${dst}/workload/${burst_pos}.stdout \
		2> ${dst}/workload/${burst_pos}.stderr
	exitcode=$?
	set -e

	if [ $exitcode != 0 ]
	then
		break
	fi
done

list_workload_bpf_progs --json post
dump_workload_bpf_progs post

sudo kill -SIGINT $tracer_pid || true # might have terminated already
sleep 5 && sudo kill -SIGKILL $tracer_pid || true

set +e
wait $tracer_pid
tracer_ec=$?
set -e

if grep 'failed to load BPF' $dst/workload/trace
then
	tracer_ec=1
fi

# Must run in same cwd as _PREPARE.
bash -c "export OSE_RANDOM_PORT='$OSE_RANDOM_PORT'; ${OSE_WORKLOAD_CLEANUP}"

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode
echo -n $tracer_ec > ${dst}/values/tracer_exitcode
