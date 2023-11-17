#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
set -x

dst=$1
burst_len=$2

mkdir -p $dst/values $dst/log

. ./common.sh
loxilb_workflow=tcplb #tcpsctpperf #

# Kill processes from previous runs that did not properly terminate.
rmconfig() {
	set +e
	env -C $loxilb_src/cicd/$loxilb_workflow ./rmconfig.sh
	set -e
}

rmconfig
docker ps --all
ip netns list
env -C $loxilb_src/cicd/$loxilb_workflow ./config.sh

./bench-runtime-begin.sh $@

sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	set +e
	env -C $loxilb_src/cicd/$loxilb_workflow ./validation.sh
	exitcode=$?
	set -e

	if [ $exitcode != 0 ]
	then
		break
	fi
done

docker exec -i llb1 bash -c 'cat /var/log/loxilb*.log' > $dst/log/llb1-loxilb.log

./bench-runtime-end.sh $@

rmconfig

echo -n $exitcode > ${dst}/values/workload_exitcode
