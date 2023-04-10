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
        memcached libevent-openssl-2.1-7 \
        arping bison clang-format cmake dh-python \
        dpkg-dev pkg-kde-tools ethtool flex inetutils-ping iperf \
        libbpf-dev libclang-dev libclang-cpp-dev libedit-dev libelf-dev \
        libfl-dev libzip-dev linux-libc-dev llvm-dev libluajit-5.1-dev \
        luajit python3-netaddr python3-pyroute2 python3-setuptools python3

    sudo systemctl disable memcached

    prefix=/usr/local
    stow=$prefix/stow
    sudo mkdir -p $stow
    for t in bpf perf
    do
        r=linux-tools-$t-$(uname -r)
        if ! test -d $stow/$r
        then
                # Don't know why they put the prefix after the DESTDIR...
                tmp=$(mktemp -d)
                sudo make DESTDIR=$tmp prefix=$prefix STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools ${t}_install
                sudo mv $tmp$prefix $stow/$r
                sudo rm -rfd $tmp
        fi
        pushd $stow
        sudo stow --override '.*' --stow $r
        popd
    done

    # TODO: fix for debian, rm from release.mk
    r=bcc
    if ! test -d $stow/$r && false
    then
            # Don't know why they put the prefix after the DESTDIR...
            tmp=$(mktemp -d)
            # make -j $(nproc) -C ../target_prefix/bcc clean
            # rm -rfd ../target_prefix/bcc/build
            # mkdir -p ../target_prefix/bcc/build
            # pushd ../target_prefix/bcc/build
            # cmake ..
            pushd ../target_prefix/bcc/libbpf-tools # built on control system by release.mk
            sudo rm -rfd .output
            sudo make clean
            # make -j $(nproc) APPS=bashreadline
            sudo make DESTDIR=$tmp prefix=$prefix APPS=bashreadline install
            popd
            sudo mv $tmp$prefix $stow/$r
            sudo rm -rfd $tmp
    fi
    # pushd $stow
    # sudo stow --override '.*' --stow $r
    # popd

    if ! test -d /usr/lib/llvm-15/bin
    then
            wget https://apt.llvm.org/llvm.sh
            chmod +x llvm.sh
            sudo ./llvm.sh 15 all
    fi

    # TODO: The assumes the following tools are not modified. If they work,
    # reinstall is skipped. If we modify the tools in the linux tree, we should
    # use install-prefix + stow.

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

    # Debian has these installed by default.
    if ! sudo --non-interactive cpupower frequency-info
    then
            prefix=/usr
            stow=$prefix/stow
            sudo mkdir -p $stow
            for t in cpupower
            do
                r=linux-tools-$t-$(uname -r)
                if ! test -d $stow/$r
                then
                        # Don't know why they put the prefix after the DESTDIR...
                        tmp=$(mktemp -d)
                        sudo make DESTDIR=$tmp prefix=$prefix STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools ${t}_install
                        sudo mv $tmp$prefix $stow/$r
                        sudo rm -rfd $tmp
                fi
                pushd $stow
                sudo stow --override '.*' --stow $r
                popd
            done
    fi

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
