#!/usr/bin/env bash
set -euo pipefail
set -x

./scripts/target-scpsh -C target-scripts "USER=$USER ./cleanup.sh"
./scripts/target-scpsh -C target-scripts "./cleanup.sh"
./scripts/target-scpsh -C target-scripts "sudo reboot"
