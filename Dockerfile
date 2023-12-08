# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

FROM debian:bullseye

ARG USER
ARG UID
ARG HOME
ARG DEBIAN_FRONTEND=noninteractive

# Base packages to retrieve the other repositories/packages
RUN apt-get update && apt-get install --yes --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg

# Add additional packages here.
RUN apt-get update && apt-get install --yes --no-install-recommends \
    arch-test \
    autoconf \
    automake \
    autotools-dev \
    bash-completion \
    bc \
    binfmt-support \
    bison \
    bsdmainutils \
    build-essential \
    cpio \
    curl \
    diffstat \
    flex \
    g++-riscv64-linux-gnu \
    gawk \
    gcc-riscv64-linux-gnu \
    gdb \
    gettext \
    git \
    git-lfs \
    gperf \
    groff \
    less \
    libelf-dev \
    liburing-dev \
    lsb-release \
    mmdebstrap \
    ninja-build \
    patchutils \
    perl \
    pkg-config \
    psmisc \
    python-is-python3 \
    python3-venv \
    qemu-user-static \
    rsync \
    ruby \
    ssh \
    strace \
    texinfo \
    traceroute \
    unzip \
    vim \
    zlib1g-dev \
    lsb-release \
    wget \
    software-properties-common \
    gnupg \
    cmake \
    libdw-dev \
    libssl-dev \
    python3-docutils \
    kmod \
    zsh \
    pigz \
    sudo \
    iputils-ping \
    debhelper \
	ccache \
    trash-cli \
    zstd \
    clang-13

RUN echo 'deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-16 main' > /etc/apt/sources.list.d/llvm.list
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

RUN apt update

# LLVM
RUN apt-get install --yes libllvm-16-ocaml-dev libllvm16 llvm-16 llvm-16-dev llvm-16-doc llvm-16-examples llvm-16-runtime
# Clang and co
RUN apt-get install --yes clang-16 clang-tools-16 clang-16-doc libclang-common-16-dev libclang-16-dev libclang1-16 clang-format-16 python3-clang-16 clangd-16 clang-tidy-16
# compiler-rt
RUN apt-get install --yes libclang-rt-16-dev
# polly
RUN apt-get install --yes libpolly-16-dev
# libfuzzer
RUN apt-get install --yes libfuzzer-16-dev
# lldb
RUN apt-get install --yes lldb-16
# lld (linker)
RUN apt-get install --yes lld-16

# Ick. BPF requires pahole "supernew" to work
RUN cd $(mktemp -d) && git clone https://git.kernel.org/pub/scm/devel/pahole/pahole.git && \
    cd pahole && mkdir build && cd build && cmake -D__LIB=lib .. && make install

RUN apt-get install --yes autossh dwarves golang gcc-multilib

# Authorize SSH Host
# RUN mkdir -p /root/.ssh && chmod 0700 /root/.ssh

# COPY "$HOME/.ssh/known_hosts" /root/.ssh/known_hosts
# COPY "$HOME/.ssh/config.default" /root/.ssh/config
# COPY "$HOME/.ssh/id_rsa" /root/.ssh/id_rsa
# COPY "$HOME/.ssh/id_rsa.pub" /root/.ssh/id_rsa.pub

# Add the keys and set permissions
# RUN chmod 600 /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa.pub

RUN echo "$USER *=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN useradd -rm -d $HOME -s /usr/bin/zsh -g root -G sudo -u $UID $USER
USER $USER
WORKDIR $HOME

# The workspace volume is for bind-mounted source trees.
# VOLUME /
