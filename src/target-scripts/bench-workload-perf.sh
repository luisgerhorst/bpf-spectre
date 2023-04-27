#!/usr/bin/env bash
set -euo pipefail
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

mkdir -p $dst/workload $dst/values

# Environment from suite definition:
export PERF_EVENTS=${PERF_EVENTS:-"-e instructions -e cycles -e branch-misses"}
export PERF_FLAGS=${PERF_FLAGS:-} # e.g. --all-cpus
export WORKLOAD_PREPARE="${WORKLOAD_PREPARE:-true}"
export WORKLOAD_CLEANUP="${WORKLOAD_CLEANUP:-true}"

# Available to workload:
export RANDOM_PORT="$(random_port)"

./bench-runtime-begin.sh $@

bash -c "export RANDOM_PORT='$RANDOM_PORT'; ${WORKLOAD_PREPARE}"

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	set +e
	env -i sudo --preserve-env perf stat \
		--output ${dst}/workload/${burst_pos}.perf -x , \
		-e duration_time \
		-e task-clock \
		-e raw_syscalls:sys_enter \
		${PERF_EVENTS} \
		bash -c "export RANDOM_PORT='$RANDOM_PORT'; ${WORKLOAD}" \
		> ${dst}/workload/${burst_pos}.stdout \
		2> ${dst}/workload/${burst_pos}.stderr
	exitcode=$?
	set -e

	if [ $exitcode != 0 ]
	then
		break
	fi
done

# Must run in same pwd as _PREPARE.
bash -c "export RANDOM_PORT='$RANDOM_PORT'; ${WORKLOAD_CLEANUP}"

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode
