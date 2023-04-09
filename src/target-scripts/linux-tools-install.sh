#!/usr/bin/env bash
{
    set -euo pipefail
    shopt -s nullglob
    set -x


    sudo --non-interactive apt-get -y --fix-broken install # install deps

    # Ubuntu and Debian:
    sudo --non-interactive apt-get --assume-yes install \
        libcap-ng-dev libfuse-dev libpci-dev libcap-dev make gcc binutils-dev libreadline-dev libbison-dev flex libelf-dev \
        dwarves gettext stow \
        memcached

    sudo systemctl disable memcached

    # Debian-only:
    sudo --non-interactive apt-get --assume-yes install \
        libcpupower-dev bpftool \
        || true


    prefix=/usr/local
    stow=$prefix/stow
    sudo mkdir -p $stow
    br=bpftool-$(uname -r)
    if ! test -d $stow/$br
    then
            # Don't know why the put the prefix after the DESTDIR...
            tmp=$(mktemp -d)
            sudo make DESTDIR=$tmp prefix=$prefix STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools bpf_install
            sudo mv $tmp$prefix $stow/$br
    fi
    pushd $stow
    sudo stow --override '.*' --stow $br
    popd

    if ! test -d /usr/lib/llvm-15/bin
    then
            wget https://apt.llvm.org/llvm.sh
            chmod +x llvm.sh
            sudo ./llvm.sh 15 all
    fi

    if ! memtier_benchmark --version
    then
            tmp=$(mktemp -d)
            deb=memtier-benchmark_1.4.0.bullseye_amd64.deb
            pushd $tmp
            wget https://github.com/RedisLabs/memtier_benchmark/releases/download/1.4.0/$deb
            sudo --non-interactive dpkg -i $deb                                      # announce deps
            sudo --non-interactive apt-get -y --fix-broken install # install deps
            sudo --non-interactive dpkg -i $deb # install
            memtier_benchmark --version
            popd
            rm -rfd $tmp
    fi

    # TODO: The assumes the following tools are not modified. If they work,
    # reinstall is skipped. If we modify the tools in the linux tree, we should
    # use install-prefix + stow.
    
	sudo --non-interactive cpupower frequency-info \
        || sudo make STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools cpupower_install

    # if ! ../target_prefix/linux-src/tools/testing/selftests/bpf/bench --help
    # then
    #         make -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src oldconfig prepare
    #         make SKIP_TARGETS="alsa memfd net netfilter vm x86" FORCE_TARGETS=1 TEST_GEN_PROGS= \
    #             -j $(getconf _NPROCESSORS_ONLN) -k -C ../target_prefix/linux-src/tools/testing/selftests \
    #             install || true
    #         ../target_prefix/linux-src/tools/testing/selftests/bpf/bench --help
    # fi

    exit
}
