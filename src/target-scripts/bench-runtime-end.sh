#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
set -x

dst=$1
OSE_DEBUG=${OSE_DEBUG:-"0"}

sudo dmesg > ${dst}/dmesg &

if [[ $OSE_DEBUG == "1" ]]
then
	sudo cat /sys/kernel/debug/tracing/trace || true > ${dst}/trace
	sudo dmesg \
		| env -C ../target_prefix/linux-src ./scripts/decode_stacktrace.sh ./vmlinux \
		> ${dst}/dmseg.decoded-stacktrace.log &
	sudo sysctl --all > $dst/sysctl.d/final &
fi

wait

if ls /sys/devices/system/cpu/cpu0/cpufreq/ > /dev/null
then
	min_freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
	max_freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
	old_governor=$(cat cpufreq-governor)
	sudo cpupower frequency-set \
		--min ${min_freq_khz}kHz --max ${max_freq_khz}kHz \
		--governor ${old_governor} &
fi

echo 1 > sudo tee /proc/sys/kernel/nmi_watchdog &

sudo sysctl --load=$dst/sysctl.d/default 2> /dev/null 1> /dev/null &

wait
