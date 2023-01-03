#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"

set -x

# Arguments from suite runner:
output_abs=$1
burst_len=$2

# Environment from suite definition:
CPUFREQ=${CPUFREQ:-max}
PERF_EVENTS=${PERF_EVENTS:-"-e instructions -e iTLB-load-misses -e dTLB-load-misses -e branch-misses"}

pushd ../linux-build

# Set's default T and related variables.
. ./env.sh

# Prepares target with linux-build ready for target-scpsh.
make all

./scripts/target-scpsh 'uname -a' > ${output_abs}/uname-a
./scripts/target-scpsh 'lscpu'    > ${output_abs}/lscpu

./scripts/target-scpsh "echo 0 > sudo tee /proc/sys/kernel/nmi_watchdog"

if [[ "${T}" != "qemu-debian" ]]
then
	old_governor=$(./scripts/target-scpsh 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')

	if [[ "${CPUFREQ}" == "max" ]]
	then
		cpufreq_khz=$(./scripts/target-scpsh 'cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq')
	else
		if [[ "${T}" == easy7 ]] # base_frequency file does not exist here
		then
			cpufreq_khz=2800000 # highest available non-boost freq
		else
			cpufreq_khz=$(./scripts/target-scpsh "cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency")
		fi
	fi
	./scripts/target-scpsh "sudo cpupower frequency-set --min ${cpufreq_khz}kHz --max ${cpufreq_khz}kHz --governor performance"
	./scripts/target-scpsh 'sudo cpupower frequency-info' > ${output_abs}/cpupower-frequency-info
fi

./scripts/target-scpsh 'grep . /sys/devices/system/cpu/vulnerabilities/*' > ${output_abs}/cpu-vulnerabilities

set +e
./scripts/target-scpsh -o "${output_abs}/workload" "
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in \$(seq 0 \$(expr ${burst_len} - 1))
do
env -i sudo perf_\$(uname -r) stat --output ../result_dir/\${burst_pos}.perf -x , \
-e duration_time \
-e task-clock \
-e raw_syscalls:sys_enter \
${PERF_EVENTS} \
${WORKLOAD} \
> ../result_dir/\${burst_pos}.stdout 2> ../result_dir/\${burst_pos}.stderr
done
"
exitcode=$?
set -e

td=$(mktemp -d)
./scripts/target-scpsh -o ${td}/result_dir 'sudo cat /sys/kernel/debug/tracing/trace > ../result_dir/trace || true'
mv ${td}/result_dir/trace ${output_abs}/trace
rm -rfd ${td}

./scripts/target-scpsh "sudo dmesg" > ${output_abs}/dmesg

./scripts/target-scpsh "echo 1 > sudo tee /proc/sys/kernel/nmi_watchdog"

if [[ "${T}" != "qemu-debian" ]]
then
	min_freq_khz=$(./scripts/target-scpsh "cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq")
	max_freq_khz=$(./scripts/target-scpsh "cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
	./scripts/target-scpsh "sudo cpupower frequency-set --min ${min_freq_khz}kHz --max ${max_freq_khz}kHz --governor ${old_governor}"
fi

echo -n $exitcode > ${output_abs}/workload-exitcode
