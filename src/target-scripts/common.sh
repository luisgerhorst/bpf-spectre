loxilb_version=0.9.0
loxilb_url=ghcr.io/loxilb-io/loxilb:v$loxilb_version

# copy of local fork
loxilb_src=../target_prefix/loxilb

# Tool / software events have virtually no overhead to collect.
OSE_PERF_DEFAULT_EVENTS=${OSE_PERF_DEFAULT_EVENTS:-"-e duration_time -e user_time -e system_time \
    -e alignment-faults -e bpf-output -e cgroup-switches \
    -e context-switches -e cpu-clock -e cpu-migrations -e dummy -e emulation-faults \
    -e major-faults -e minor-faults -e page-faults -e task-clock"}
OSE_PERF_EVENTS=${OSE_PERF_EVENTS:-"-e cycles -e instructions -e power/energy-pkg/ -e power/energy-ram/ -e power/energy-cores/ -e cycle_activity.stalls_total -e uops_retired.stall_cycles"}

list_workload_bpf_progs() {
	flags="$1"
	first_suffix="$2"

	last_suffix=""
	if [[ "$flags" == "--json" ]]
	then
		flags="--json --pretty"
		last_suffix=".json"
	fi

	sudo bpftool prog show $flags > $dst/workload/${first_suffix}.bpftool_prog_show${last_suffix} 2>&1
}

# dump_workload_bpf_progs() {
# 	suffix="$1"

# 	set +x
# 	IFS=$'\n'
# 	for	line in $(cat $dst/workload/${suffix}.bpftool_prog_show.json)
# 	do
# 		if [[ $(echo "$line" | cut -d '"' -f 2) == "id" ]]
# 		then
# 			# Program ID:
# 			prog=$(echo "$line" | cut -d ':' -f 2 | cut -d , -f 1 | cut -d ' ' -f 2)
# 		fi
# 	done
# 	unset IFS
# 	set -x
# }

dump_workload_bpf_progs() {
	suffix="$1"

	echo -n "" > ${dst}/values/bpftool_progs.$suffix
	set +x
	IFS=$'\n'
	for	line in $(cat $dst/workload/${suffix}.bpftool_prog_show.json)
	do
		if [[ $(echo "$line" | cut -d '"' -f 2) == "id" ]]
		then
			# Program ID:
			prog=$(echo "$line" | cut -d ':' -f 2 | cut -d , -f 1 | cut -d ' ' -f 2)
			echo "prog=$prog" 1>&2

			set +e
			sudo bpftool --json --pretty prog dump xlated id "$prog" > ${bpftool_dst}/xlated.${prog}.${suffix}.json
			e1=$?
			sudo bpftool --json --pretty prog dump jited id "$prog" > ${bpftool_dst}/jited.${prog}.${suffix}.json
			e2=$?
			set -e

			# Dump may fail spuriously.
			if [ $e1 = 0 ] && [ $e2 = 0 ]
			then
				echo -n " $prog" >> ${dst}/values/bpftool_progs.${suffix}
			fi
		fi
	done
	unset IFS
	set -x
}
