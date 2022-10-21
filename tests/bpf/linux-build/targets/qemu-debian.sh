export VM=debian

export SSH_DEST=root@localhost
export SSH_PORT=$(cat .run/${VM}.ssh_port)
export CONFIG=configs/${T}
