VM=debian

SSH_DEST=root@localhost
SSH_PORT=$(shell cat .run/$(VM).ssh_port)
CONFIG=configs/$(T)
