#!/usr/bin/env bash
set -euo pipefail
set -x

t=""
c=""
a=""
for arg in "$@"
do
    if [ "$arg" = "--siw-trace" ] || [ "$arg" = "--siw-command" ]
    then
        a=$arg
    elif [ "$a" = "--siw-command" ]
    then
        c="$c $arg"
    elif [ "$a" = "--siw-trace" ]
    then
        t="$t $arg"
    fi
done

set -m
$t 1> $(basename $0).stdout 2> $(basename $0).stderr &
$c

# TODO: Maybe exclude these from perf stat.
bpftool prog show

kill -SIGINT %%
set +e
wait %%
ec=$?
set -e
cat $(basename $0).stdout 1>&2
cat $(basename $0).stderr 1>&2
exit $ec
