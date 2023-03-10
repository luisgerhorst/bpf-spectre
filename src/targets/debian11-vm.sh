# Set up your .ssh/config with correct ProxyJump and User.
export SSH_DEST=debian@${T}.local
export SSH_PORT=${SSH_PORT:-22}
export CONFIG=configs/i4lab
