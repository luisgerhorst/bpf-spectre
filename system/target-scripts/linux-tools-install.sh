#!/usr/bin/env bash
{
    set -euo pipefail
    set -x

    sudo --non-interactive apt-get --assume-yes install clang libcap-ng-dev libfuse-dev libcpupower-dev libpci-dev libcap-dev make gcc binutils-dev libreadline-dev libbison-dev flex libelf-dev

    # TODO: The assumes the tools are not modified. If they work, reinstall is
    # skipped. If we modify the tools, we should use install-prefix + stow.

	sudo --non-interactive bpftool --help \
        || sudo make STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools bpf_install

	sudo --non-interactive cpupower frequency-info \
        || sudo make STATIC=true -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src/tools cpupower_install

    if ! ../target_prefix/linux-src/tools/testing/selftests/bpf/bench --help
    then
            make -j $(getconf _NPROCESSORS_ONLN) -C ../target_prefix/linux-src oldconfig prepare
            # TODO: Test this.
            make SKIP_TARGETS="alsa memfd net netfilter vm x86" FORCE_TARGETS=1 TEST_GEN_PROGS= \
                -j $(getconf _NPROCESSORS_ONLN) -k -C ../target_prefix/linux-src \
                kselftest-install \
                || true
            ../target_prefix/linux-src/tools/testing/selftests/bpf/bench --help
    fi

    exit
}
