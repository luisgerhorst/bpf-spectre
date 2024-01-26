loxilb_version=0.9.0
loxilb_url=ghcr.io/loxilb-io/loxilb:v$loxilb_version

# copy of local fork
loxilb_src=../target_prefix/loxilb

OSE_PERF_EVENTS=${OSE_PERF_EVENTS:-"-e cycles -e instructions -e power/energy-pkg/ -e power/energy-ram/ -e power/energy-cores/ -e cycle_activity.stalls_total -e uops_retired.stall_cycles"}
