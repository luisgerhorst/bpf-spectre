# Set up your .ssh/config with correct ProxyJump and User.
export SSH_DEST=gerhorst@${T}
export SSH_PORT=${SSH_PORT:-22}
export CONFIG=configs/debian.local
