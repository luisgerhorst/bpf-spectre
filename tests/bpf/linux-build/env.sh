export TARGET_SSH="ssh ${SSH_DEST} -p ${SSH_PORT} -o BatchMode=true -o NoHostAuthenticationForLocalhost=true"
export TARGET_SCP="scp -P ${SSH_PORT} -B -o NoHostAuthenticationForLocalhost=true -q"

export TARGET_EXEC="./scripts/target-exec ${SSH_DEST} ${SSH_PORT}"

export TARGET_PREFIX='~/tmp/bpftask'
export TARGET_PERF='./linux-perf/perf-*/tools/perf/perf'
