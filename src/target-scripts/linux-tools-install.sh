#!/usr/bin/env bash
{
    set -euo pipefail
    shopt -s nullglob
    bash -n "$(command -v "$0")"
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
        python3-dev libdwarf-dev libdw-dev libssl-dev libunwind-dev libssl-dev \
        python3-docutils

    # HACK to build bcc libbpf-tools javagc on Debian
    # https://stackoverflow.com/questions/14795608/asm-errno-h-no-such-file-or-directory
    test -e /usr/include/asm \
        || sudo ln -s /usr/include/asm-generic /usr/include/asm

    sudo systemctl disable memcached

    LLVM_VERSION=16
    if ! test -d /usr/lib/llvm-$LLVM_VERSION/bin
    then
            wget https://apt.llvm.org/llvm.sh
            chmod +x llvm.sh
            sudo ./llvm.sh $LLVM_VERSION all
    fi
    export PATH=/usr/lib/llvm-$LLVM_VERSION/bin:$PATH # required for bcc/libbpf-tools
    SUDO="sudo --preserve-env=PATH"

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
                $SUDO make DESTDIR=$tmp prefix=$prefix STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools ${t}_install
                sudo mv $tmp$prefix $stow/$r
                sudo rm -rfd $tmp
        fi
        pushd $stow
        sudo stow --override '.*' --stow $r
        popd
    done

    # r=bcc-libbpf-tools-${BCC_LOCALVERSION}
    # if ! test -d $stow/$r
    # then
    #         tmp=$(mktemp -d)
    #         pushd ../target_prefix/bcc/libbpf-tools
    #         $SUDO make USE_BLAZESYM=0 -j $(nproc) clean
    #         sudo chown -R $USER .
    #         make USE_BLAZESYM=0 -j $(nproc) -k all || true
    #         $SUDO make USE_BLAZESYM=0 DESTDIR=$tmp prefix=$prefix -k install || true
    #         popd
    #         sudo mv $tmp$prefix $stow/$r
    #         sudo rm -rfd $tmp
    # fi
    # pushd $stow
    # sudo stow --override '.*' --stow $r
    # popd

    parca_version=0.23.3
    r=parca-agent-v$parca_version
    if ! test -d $stow/$r
    then
            tmp=$(mktemp -d)
            pushd $tmp
            curl -L https://github.com/parca-dev/parca-agent/releases/download/v$parca_version/parca-agent_${parca_version}_`uname -s`_`uname -m`.tar.gz | tar xvfz -
            popd
            sudo mkdir -p $stow/$r/bin
            sudo mv $tmp/parca-agent $stow/$r/bin/parca-agent
    fi
    pushd $stow
    sudo stow --override '.*' --stow $r
    popd

    test="sudo docker run hello-world"
    if ! $test
    then
            # Add Docker's official GPG key:
            sudo apt-get update
            sudo apt-get --non-interactive --assume-yes install ca-certificates curl gnupg
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg

            # Add the repository to Apt sources:
            echo \
                "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update

            # Install the Docker packages.
            sudo apt-get --non-interactive --assume-yes install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            # Verify that the installation is successful by running the hello-world image:
            $test
    fi

    loxilib_version=0.8.8
    url=ghcr.io/loxilb-io/loxilb:v$loxilib_version
    t="docker run -u root --cap-add SYS_ADMIN --privileged -v /dev/log:/dev/log -it $url loxilib --version"
    if ! $test
    then
            # https://loxilb-io.github.io/loxilbdocs/simple_topo/
            sudo docker pull $url

            $test
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
                        $SUDO make DESTDIR=$tmp prefix=$prefix STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools ${t}_install
                        sudo mv $tmp$prefix $stow/$r
                        sudo rm -rfd $tmp
                fi
                pushd $stow
                sudo stow --override '.*' --stow $r
                popd
            done
    fi

    if ! ../target_prefix/kselftest/bpf/bench --help > /dev/null
    then
            false # should not be needed

            # bpf requires all.
            make -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src oldconfig prepare headers all
            make SKIP_TARGETS="alsa memfd net netfilter vm x86" FORCE_TARGETS=1 TEST_GEN_PROGS= \
                -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools/testing/selftests \
                install || true
            ../target_prefix/linux-src/tools/testing/selftests/bpf/bench --help
            ../target_prefix/kselftest/bpf/test_progs --help # test
    fi

    exit
}
