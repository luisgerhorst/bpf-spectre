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
        luajit python3-netaddr python3-pyroute2 python3-setuptools python3 \
        libz-dev libbpf-dev libtraceevent-dev curl \
        python3-dev libdwarf-dev libdw-dev libssl-dev libunwind-dev libssl-dev

    # HACK to build bcc libbpf-tools javagc on Debian
    # https://stackoverflow.com/questions/14795608/asm-errno-h-no-such-file-or-directory
    test -e /usr/include/asm \
        || sudo ln -s /usr/include/asm-generic /usr/include/asm

    sudo systemctl disable memcached

    if ! test -d /usr/lib/llvm-15/bin
    then
            wget https://apt.llvm.org/llvm.sh
            chmod +x llvm.sh
            sudo ./llvm.sh 15 all
    fi
    export PATH=/usr/lib/llvm-15/bin:$PATH # required for bcc/libbpf-tools

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

    r=bcc-libbpf-tools-${BCC_LOCALVERSION}
    if ! test -d $stow/$r
    then
            tmp=$(mktemp -d)
            pushd ../target_prefix/bcc/libbpf-tools
            sudo make USE_BLAZESYM=0 -j $(nproc) clean
            sudo chown -R $USER .
            make USE_BLAZESYM=0 -j $(nproc) -k all || true
            sudo make USE_BLAZESYM=0 DESTDIR=$tmp prefix=$prefix -k install || true
            popd
            sudo mv $tmp$prefix $stow/$r
            sudo rm -rfd $tmp
    fi
    pushd $stow
    sudo stow --override '.*' --stow $r
    popd

    r=parca-agent-v0.19.0
    if ! test -d $stow/$r
    then
            tmp=$(mktemp -d)
            pushd $tmp
            curl -sL https://github.com/parca-dev/parca-agent/releases/download/v0.19.0/parca-agent_0.19.0_`uname -s`_`uname -m`.tar.gz | tar xvfz -
            popd
            sudo mkdir -p $stow/$r/bin
            sudo mv $tmp/parca-agent $stow/$r/bin/parca-agent
    fi
    pushd $stow
    sudo stow --override '.*' --stow $r
    popd

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
