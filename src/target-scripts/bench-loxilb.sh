#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
set -x

dst=$1
burst_len=$2

mkdir -p $dst/values $dst/log

./bench-runtime-begin.sh $@

. ./common.sh

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	set +e
	env -C $loxilb_src act -j build -W .github/workflows/perf.yml --privileged
	exitcode=$?
	set -e

	if [ $exitcode != 0 ]
	then
		break
	fi
done

./bench-runtime-end.sh $@

echo -n $exitcode > ${dst}/values/workload_exitcode
