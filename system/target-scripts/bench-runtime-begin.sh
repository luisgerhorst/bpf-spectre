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
	elif [[ "${CPUFREQ}" == 'min' ]]
	then
		cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
	elif [[ "${CPUFREQ}" == 'base' ]]
	then
		if cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency > /dev/null
		then
			cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency)
		elif lscpu | grep 'AMD Ryzen 9 3950X' > /dev/null
		then
			cpufreq_khz=2800000
		elif lscpu | grep 'CPU @ 3.30GHz' > /dev/null
		then
			cpufreq_khz=3300000
		elif lscpu | grep 'CPU @ 2.80GHz' > /dev/null
		then
			cpufreq_khz=2800000
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

if [ -e /tmp/$USER-sysctl-backup.conf ]
then
	sudo sysctl --load=/tmp/$USER-sysctl-backup.conf > /dev/null
else
	sudo sysctl --all > /tmp/$USER-sysctl-backup.conf > /dev/null
fi
sudo sysctl --system > /dev/null

sudo sysctl --version > $dst/sysctl.version
sudo sysctl --all > $dst/sysctl.default
sudo sysctl --write kernel.panic=30 $SYSCTL # Dummy kernel.panic parameter required.
sudo sysctl --all > $dst/sysctl

set +x
IFS=$'\n'
for p in $(sudo find "/proc/sys/kernel/" -type f)
do
	sudo cat $p > ${dst}/values/kernel_$(basename $p)
done
for p in $(sudo find "/proc/sys/net/core/" -type f)
do
	sudo cat $p > ${dst}/values/net_core_$(basename $p)
done
unset IFS
set -x

set +e
sudo systemctl status fai-boot.service > $dst/fai_status
sudo systemctl status run-fai.service >> $dst/fai_status
sudo systemctl status run-fai.timer >> $dst/fai_status
set -e

if cat /var/run/fai/fai*_is_running
then
   exit 1
fi
