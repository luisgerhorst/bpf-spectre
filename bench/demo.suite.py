#!/usr/bin/env python3

import sys
import logging
import math

import yaml # pyyaml

def main():
    logging.basicConfig(level=logging.DEBUG)

    suite = []

    target = "qemu-debian"

    suite.append({
        "command": "bench-workload.sh",
        "boot": {
            "T": target,
        },
        "run": {
            "WORKLOAD": "sleep 1",
        },
    })

    yaml.dump(suite, sys.stdout)

if __name__ == "__main__":
    main()
