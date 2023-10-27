#!/usr/bin/env bash
set -euo pipefail
bash -n "$(command -v "$0")"
shopt -s nullglob
set -x

./docker-build.sh

name=$(basename $(pwd))

docker run --tty --interactive \
	--volume $HOME:$HOME \
	--volume /srv/scratch/$USER:/srv/scratch/$USER \
	--network=host \
	-h $name.$(hostname) \
	--env USER=$USER \
	$name /usr/bin/zsh
