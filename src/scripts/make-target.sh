#!/usr/bin/env bash
set -euo pipefail
set -x

make_targets=$1

./scripts/target-linux-deb-boot .build/linux-pkg

${MAKE} -f release.mk $1
