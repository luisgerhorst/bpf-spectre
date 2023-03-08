#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
set -x

dst=$1

# Environment from suite definition:
export CPUFREQ=${CPUFREQ:-max}

mkdir -p $dst/workload $dst/values

if cat /var/run/fai/fai*_is_running
then
   exit 1
fi

echo 0 > sudo tee /proc/sys/kernel/nmi_watchdog &

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
		--governor performance &
fi

mkdir $dst/sysctl.d
sudo sysctl --version > $dst/sysctl.d/version &
sudo sysctl --system 2>&1 > /dev/null
sudo sysctl --write kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=0 || true # not supported on mainline
sudo sysctl --write net.core.bpf_jit_harden=0
sudo sysctl --all > $dst/sysctl.d/default
sudo sysctl --write kernel.panic=30 $SYSCTL # Dummy kernel.panic parameter required.

wait

#
# Record system config
#

set +e
sudo systemctl status fai-boot.service run-fai.service run-fai.timer > $dst/fai-status &
set -e

sudo cpupower frequency-info > ${dst}/cpupower-frequency-info &

lscpu > ${dst}/lscpu &
grep . /sys/devices/system/cpu/vulnerabilities/* > ${dst}/cpu-vulnerabilities &

uname -a > ${dst}/values/uname_a &
hostname --short > ${dst}/values/hostname_short &

sudo sysctl --all > $dst/sysctl.d/all &

set +x
IFS=$'\n'
for p in $(sudo find "/proc/sys/kernel/" -type f)
do
	sudo cat $p > ${dst}/values/kernel_$(basename $p) &
done
for p in $(sudo find "/proc/sys/net/core/" -type f)
do
	sudo cat $p > ${dst}/values/net_core_$(basename $p) &
done
unset IFS
set -x

wait
