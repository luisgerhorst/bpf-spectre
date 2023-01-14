#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
# On the SuT: Benchmarks workload performance.

set -x

dst=$1
burst_len=$2

# Environment from suite definition:
export CPUFREQ=${CPUFREQ:-max}
export PERF_EVENTS=${PERF_EVENTS:-"-e instructions -e iTLB-load-misses -e dTLB-load-misses -e branch-misses"}

if cat /var/run/fai/fai*_is_running
then
   exit 1
fi

echo 0 > sudo tee /proc/sys/kernel/nmi_watchdog

if ls /sys/devices/system/cpu/cpu0/cpufreq/ > /dev/null
then
	old_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

	if [[ "${CPUFREQ}" == 'max' ]]
	then
		cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
	else
		if cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency > /dev/null
		then
			cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency)
		elif [ $T = faui49easy7 ]
		then
			cpufreq_khz=2800000 # Ryzen 3950X highest available non-boost freq
		else
			exit 1
		fi
	fi
	sudo cpupower frequency-set \
		--min ${cpufreq_khz}kHz --max ${cpufreq_khz}kHz \
		--governor performance
	sudo cpupower frequency-info > ${dst}/cpupower-frequency-info
fi

lscpu > ${dst}/lscpu
grep . /sys/devices/system/cpu/vulnerabilities/* > ${dst}/cpu-vulnerabilities
uname -a > ${dst}/uname-a

mkdir -p ${dst}/workload
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

sudo cat /sys/kernel/debug/tracing/trace > ${dst}/trace || true
sudo dmesg > ${dst}/dmesg

echo 1 > sudo tee /proc/sys/kernel/nmi_watchdog

if ls /sys/devices/system/cpu/cpu0/cpufreq/ > /dev/null
then
	min_freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
	max_freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
	sudo cpupower frequency-set \
		--min ${min_freq_khz}kHz --max ${max_freq_khz}kHz \
		--governor ${old_governor}
fi

echo -n $exitcode > ${dst}/workload-exitcode
