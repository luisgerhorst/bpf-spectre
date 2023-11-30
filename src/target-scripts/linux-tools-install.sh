#!/usr/bin/env bash
{
    set -euo pipefail
    shopt -s nullglob
    bash -n "$(command -v "$0")"
    set -x

    SUDO="sudo --non-interactive --preserve-env=PATH"
    APT="apt-get --assume-yes"

    $SUDO $APT --fix-broken install # install deps

    # Ubuntu and Debian:
    $SUDO $APT install \
        libcap-ng-dev libfuse-dev libpci-dev libcap-dev make gcc binutils-dev libreadline-dev libbison-dev flex libelf-dev \
        dwarves gettext stow \
        memcached libevent-openssl-2.1-7 \
        arping bison clang-format cmake dh-python \
        dpkg-dev pkg-kde-tools ethtool flex inetutils-ping iperf \
        libbpf-dev libclang-dev libclang-cpp-dev libedit-dev libelf-dev \
        libfl-dev libzip-dev linux-libc-dev llvm-dev libluajit-5.1-dev \
        luajit python3-netaddr python3-pyroute2 python3-setuptools python3 \
        libz-dev libbpf-dev libtraceevent-dev curl \
        python3-dev libdwarf-dev libdw-dev libunwind-dev \
        python3-docutils \
        net-tools nodejs \
        netperf

    $SUDO $APT install \
            libssl-dev \
            || [[ "$(lsb_release --codename | cut -f2)" == "jammy" ]]

    # HACK to build bcc libbpf-tools javagc on Debian
    # https://stackoverflow.com/questions/14795608/asm-errno-h-no-such-file-or-directory
    test -e /usr/include/asm \
        || $SUDO ln -s /usr/include/asm-generic /usr/include/asm

    $SUDO systemctl disable memcached

    LLVM_VERSION=16
    if ! test -d /usr/lib/llvm-$LLVM_VERSION/bin
    then
            wget https://apt.llvm.org/llvm.sh
            chmod +x llvm.sh
            $SUDO ./llvm.sh $LLVM_VERSION all
    fi
    export PATH=/usr/lib/llvm-$LLVM_VERSION/bin:$PATH # required for bcc/libbpf-tools

    prefix=/usr/local
    stow=$prefix/stow
    $SUDO mkdir -p $stow
    for t in bpf perf
    do
        r=linux-tools-$t-$(uname -r)
        if ! test -d $stow/$r
        then
                # Don't know why they put the prefix after the DESTDIR...
                tmp=$(mktemp -d)
                $SUDO make DESTDIR=$tmp prefix=$prefix STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools ${t}_install
                $SUDO mv $tmp$prefix $stow/$r
                $SUDO rm -rfd $tmp
        fi
        pushd $stow
        $SUDO stow --override '.*' --stow $r
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

    parca_version=0.26.0
    r=parca-agent-v$parca_version
    if ! test -d $stow/$r
    then
            tmp=$(mktemp -d)
            pushd $tmp
            curl -L https://github.com/parca-dev/parca-agent/releases/download/v$parca_version/parca-agent_${parca_version}_`uname -s`_`uname -m`.tar.gz | tar xvfz -
            popd
            $SUDO mkdir -p $stow/$r/bin
            $SUDO mv $tmp/parca-agent $stow/$r/bin/parca-agent
    fi
    pushd $stow
    $SUDO stow --override '.*' --stow $r
    popd

    act_version=0.2.54
    r=act-v$act_version
    if ! test -d $stow/$r
    then
            tmp=$(mktemp -d)
            pushd $tmp
            curl -L https://github.com/nektos/act/releases/download/v$act_version/act_Linux_x86_64.tar.gz | tar xvfz -
            popd
            $SUDO mkdir -p $stow/$r/bin
            $SUDO mv $tmp/act $stow/$r/bin/act
    fi
    pushd $stow
    $SUDO stow --override '.*' --stow $r
    popd

    test="docker run hello-world"
    if ! $test
    then
            # Add Docker's official GPG key:
            $SUDO $APT update
            $SUDO $APT install --assume-yes ca-certificates curl gnupg
            $SUDO rm -f /etc/apt/keyrings/docker.gpg
            $SUDO install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg | $SUDO gpg --batch --dearmor -o /etc/apt/keyrings/docker.gpg
            $SUDO chmod a+r /etc/apt/keyrings/docker.gpg

            # Add the repository to Apt sources:
            echo \
                "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
            $SUDO $APT update

            # Install the Docker packages.
            $SUDO $APT install --assume-yes docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            # https://askubuntu.com/questions/1389483/how-do-i-set-permissions-to-use-docker-with-my-normal-user
            $SUDO usermod -a -G docker $USER

            # Verify that the installation is successful by running the hello-world image:
            $SUDO $test
            echo 'docker without sudo should work after ssh reconnect, not testing' >&2
    fi

    . ./common.sh
    set +e
    test="$SUDO docker run -u root --cap-add SYS_ADMIN --privileged -v /dev/log:/dev/log -i $loxilb_url loxilib --version | grep $loxilb_version"
    if $test
    then
            set -e
            # https://loxilb-io.github.io/loxilbdocs/simple_topo/
            $SUDO docker pull $loxilb_url

            # Tag $loxilb_version at lastest for use by CI scripts.
            docker run -u root --cap-add SYS_ADMIN --restart unless-stopped \
                --privileged -dit -v /dev/log:/dev/log --name loxilb $loxilb_url
            id=`docker ps -f name=loxilb | cut  -d " "  -f 1 | grep -iv  "CONTAINER"`
            docker commit $id ghcr.io/loxilb-io/loxilb:latest
            docker stop loxilb && docker rm loxilb

            set +e
            $test
            set -e
    fi

    test="command -v iperf3"
    if ! $test
    then
            # https://github.com/loxilb-io/loxilb/blob/00b96ad49a89c8c8da7fe4b173bd5fcb353ec1e0/.github/workflows/perf.yml#L37C14-L37C211
            $SUDO $APT install llvm libelf-dev gcc-multilib libpcap-dev elfutils dwarves git libbsd-dev bridge-utils unzip build-essential bison flex iperf iproute2 nodejs socat iperf3

            $test
    fi

    # TODO: The assumes the following tools are not modified. If they work,
    # reinstall is skipped. If we modify the tools in the linux tree, we should
    # use install-prefix + stow.

    if ! memtier_benchmark --version && [[ "$(lsb_release --codename | cut -f2)" == "bullseye" ]]
    then
            tmp=$(mktemp -d)
            deb=memtier-benchmark_1.4.0.bullseye_amd64.deb
            pushd $tmp
            wget https://github.com/RedisLabs/memtier_benchmark/releases/download/1.4.0/$deb
            $SUDO dpkg -i $deb                                      # announce deps
            $SUDO $APT --fix-broken install # install deps
            $SUDO dpkg -i $deb # install
            memtier_benchmark --version
            popd
            rm -rfd $tmp
    fi

    # Debian has these installed by default.
    if ! $SUDO cpupower frequency-info
    then
            if [[ "$(lsb_release --codename | cut -f2)" == "jammy" ]]
            then
                    # Would conflict with stow.
                    $SUDO $APT remove linux-tools-generic linux-tools-common || true
                    pushd $stow/..
                    $SUDO rm -rfd bin/cpufreq-bench_plot.sh man/man1/cpupower* \
                        sbin/cpufreq-bench share/bash-completion/completions/cpupower \
                        share/doc/packages/cpupower share/locale/*/LC_MESSAGES/cpupower.mo
                    popd
            fi

            # /usr because prefix=/usr/local is not respected by make cpupower_install.
            prefix=/usr
            stow=$prefix/stow
            $SUDO mkdir -p $stow
            for t in cpupower
            do
                r=linux-tools-$t-$(uname -r)
                if ! test -d $stow/$r
                then
                        # Don't know why they put the prefix after the DESTDIR...
                        tmp=$(mktemp -d)
                        $SUDO make DESTDIR=$tmp prefix=$prefix STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools ${t}_install
                        $SUDO mv $tmp$prefix $stow/$r
                        $SUDO rm -rfd $tmp
                fi
                pushd $stow
                $SUDO stow --override '.*' --stow $r
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
