#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
# On the SuT: Benchmarks workload performance.

set -x

dst=$1
burst_len=$2

mkdir -p $dst/workload $dst/values

# Environment from suite definition:
export PERF_EVENTS=${PERF_EVENTS:-"-e instructions -e cycles -e branch-misses"}
export PERF_FLAGS=${PERF_FLAGS:-} # e.g. --all-cpus

./bench-runtime-start.sh $@

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	set +e
	env -i sudo --preserve-env $(which perf_$(uname -r)) stat \
		--output ${dst}/workload/${burst_pos}.perf -x , \
		-e duration_time \
		-e task-clock \
		-e raw_syscalls:sys_enter \
		${PERF_EVENTS} \
		${WORKLOAD} \
		> ${dst}/workload/${burst_pos}.stdout \
		2> ${dst}/workload/${burst_pos}.stderr
	exitcode=$?
	set -e

	if [ $exitcode != 0 ]
	then
		break
	fi
done

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode