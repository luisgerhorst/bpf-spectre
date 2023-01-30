#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"

set -x

dst=$1
# burst_len=$2

mkdir -p $dst/workload $dst/values

# Environment from suite definition:
export CPUFREQ=${CPUFREQ:-max}

if cat /var/run/fai/fai*_is_running
then
   exit 1
fi

echo 0 > sudo tee /proc/sys/kernel/nmi_watchdog

if ls /sys/devices/system/cpu/cpu0/cpufreq/ > /dev/null
then
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor > cpufreq-governor

	if [[ "${CPUFREQ}" == 'max' ]]
	then
		cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
	elif [[ "${CPUFREQ}" == 'base' ]]
	then
		if cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency > /dev/null
		then
			cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency)
		elif [ $T = faui49easy7 ]
		then
			cpufreq_khz=2800000 # Ryzen 3950X highest available non-boost freq
		else
			exit 1
		fi
	else
		exit 1
	fi
	sudo cpupower frequency-set \
		--min ${cpufreq_khz}kHz --max ${cpufreq_khz}kHz \
		--governor performance
	sudo cpupower frequency-info > ${dst}/cpupower-frequency-info
fi

lscpu > ${dst}/lscpu
grep . /sys/devices/system/cpu/vulnerabilities/* > ${dst}/cpu-vulnerabilities

uname -a > ${dst}/values/uname_a
hostname --short > ${dst}/values/hostname_short

set +e
sudo systemctl status fai-boot.service > $dst/fai_status
sudo systemctl status run-fai.service >> $dst/fai_status
sudo systemctl status run-fai.timer >> $dst/fai_status
set -e

if cat /var/run/fai/fai*_is_running
then
   exit 1
fi
