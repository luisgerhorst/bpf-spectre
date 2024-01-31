#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
set -x

dst=$1

# Environment from suite definition, without OSE_ (OS Eval) prefix for backwards-compatibility:
export OSE_CPUFREQ=${OSE_CPUFREQ:-${CPUFREQ:-max}}
export OSE_DEFAULT_SYSCTL="net.core.bpf_jit_harden=0 kernel.bpf_stats_enabled=1 kernel.bpf_complexity_limit_insns=2000000 kernel.bpf_complexity_limit_jmp_seq=16384 kernel.bpf_spec_v1_complexity_limit_jmp_seq=8192"
export OSE_SYSCTL="${OSE_DEFAULT_SYSCTL} ${OSE_SYSCTL:-}"

mkdir -p $dst/workload $dst/values

if cat /var/run/fai/fai*_is_running
then
   exit 1
fi

if sudo systemctl is-enabled run-fai.timer fai-boot.service
then
	echo "Do 'systemctl disable run-fai.timer fai-boot.service'!" 1>&2
	exit 1
fi

echo 0 > sudo tee /proc/sys/kernel/nmi_watchdog &

if ls /sys/devices/system/cpu/cpu0/cpufreq/ > /dev/null
then
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor > cpufreq-governor

	if [[ "${OSE_CPUFREQ}" == 'max' ]]
	then
		cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
	elif [[ "${OSE_CPUFREQ}" == 'min' ]]
	then
		cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
	elif [[ "${OSE_CPUFREQ}" == 'base' ]]
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
		elif cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies > /dev/null
		then
			# Do not choose top freq (-f 1) which may induce boost on AMD Zen 2.
			cpufreq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | cut -d ' ' -f 2)
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
sudo sysctl --system 2>&1 > /dev/null
sudo sysctl --write kernel.bpf_spec_v1=0 kernel.bpf_spec_v4=0 || true # not supported on mainline
sudo sysctl --write net.core.bpf_jit_harden=0
sudo sysctl --all > $dst/sysctl.d/default
sudo sysctl --write kernel.panic=30 $OSE_SYSCTL # Dummy kernel.panic parameter required.

wait

#
# Record system config
#

sudo cpupower frequency-info > ${dst}/cpupower-frequency-info &

lscpu > ${dst}/lscpu &
grep . /sys/devices/system/cpu/vulnerabilities/* > ${dst}/cpu-vulnerabilities &

lsb_release --description | cut -f2 > ${dst}/values/lsb_release_description &
lsb_release --codename | cut -f2 > ${dst}/values/lsb_release_codename &
uname -a > ${dst}/values/uname_a &
hostname --short > ${dst}/values/hostname_short &

sudo perf --version > ${dst}/values/perf_version &
sudo cpupower --version > ${dst}/values/cpupower_version &

sudo sysctl --version > $dst/sysctl.d/version &
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
