#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
set -x

dst=$1

sudo cat /sys/kernel/debug/tracing/trace > ${dst}/trace || true
sudo dmesg > ${dst}/dmesg

echo 1 > sudo tee /proc/sys/kernel/nmi_watchdog

if ls /sys/devices/system/cpu/cpu0/cpufreq/ > /dev/null
then
	min_freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
	max_freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
	old_governor=$(cat cpufreq-governor)
	sudo cpupower frequency-set \
		--min ${min_freq_khz}kHz --max ${max_freq_khz}kHz \
		--governor ${old_governor}
fi
