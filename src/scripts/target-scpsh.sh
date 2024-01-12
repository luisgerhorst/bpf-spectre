#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"

function usage_error() {
	echo "Usage: $0 [-C <working_dir>] [-f <file>] [-o <result_dir_dest>] [-p <target_prefix>] <command...>" >&2
	exit 1
}

env_sh="$(dirname $(command -v $0))/../env.sh"
if [ -e "$env_sh" ]
then
	. "$env_sh"
fi

working_dir_defined=0
file_defined=0
result_dir_defined=0

while getopts "C:f:o:p:" opt
do
	case ${opt} in
		C)
			working_dir_defined=1
			working_dir=${OPTARG}
			;;
		f)
			file_defined=1
			file=${OPTARG}
			;;
		o)
			result_dir_defined=1
			result_dir=${OPTARG}
			;;
		p)
			TARGET_PREFIX=${OPTARG}
			;;
		*)
			usage_error
			;;
	esac
done

command="${@:$OPTIND+0}"

ssh="ssh ${SSH_DEST} -p ${SSH_PORT} -o BatchMode=true -o NoHostAuthenticationForLocalhost=true -o ConnectionAttempts=3 -o ConnectTimeout=30"
scp="scp -P ${SSH_PORT} -B -o NoHostAuthenticationForLocalhost=true -q -o ConnectionAttempts=3 -o ConnectTimeout=30"

guest_temp=$(${ssh} mktemp -d --suffix -$USER-$(basename $0)-guest-temp)

if [ $working_dir_defined -eq 1 ]
then
	tmp=$(mktemp --suffix -$USER-$(basename $0)-working_dir.tar.gz)
	env -C $working_dir tar cf - . | pigz > $tmp
	${scp} $tmp ${SSH_DEST}:${guest_temp}/working_dir.tar.gz
	rm -f $tmp
	${ssh} mkdir ${guest_temp}/working_dir
	${ssh} tar xf ${guest_temp}/working_dir.tar.gz --directory=${guest_temp}/working_dir
fi

if [ $file_defined -eq 1 ]
then
	${scp} "${file}" "${SSH_DEST}:${guest_temp}/file"
fi

command_sh=$(mktemp --suffix -$USER-$(basename $0)-command-sh)

echo "#!/bin/bash
set -euo pipefail

mkdir -p ${TARGET_PREFIX}
ln -s ${TARGET_PREFIX} ${guest_temp}/target_prefix
mkdir ${guest_temp}/result_dir
mkdir -p ${guest_temp}/working_dir
cd ${guest_temp}/working_dir

${command}" > "${command_sh}"

chmod +x "${command_sh}"
${scp} ${command_sh} ${SSH_DEST}:${guest_temp}/command.sh

set +e
${ssh} "${guest_temp}/command.sh"
EXIT_CODE=$?
set -e

if [ $result_dir_defined -eq 1 ]
then
	${scp} -r "${SSH_DEST}:${guest_temp}/result_dir" "${result_dir}"
fi

${ssh} "rm -rd ${guest_temp}" &
rm ${command_sh} &
wait

exit $EXIT_CODE
