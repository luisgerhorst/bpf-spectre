#!/usr/bin/env python3

import argparse
import shutil
import sys
from pathlib import Path
import yaml # pyaml
import logging
import string

def parseargs():
    parser = argparse.ArgumentParser()
    parser.add_argument('output', type=str)
    parser.add_argument('log', type=str) # spectector log
    parser.add_argument('source', type=str)
    return parser.parse_args()

def main():
    logging.basicConfig(level=logging.DEBUG)
    args = parseargs()

    log = Path(args.log).read_text()
    source = Path(args.source).read_text()

    spectector_result = "NA"
    if log.__contains__("[program is safe]"):
        spectector_result = "safe"
    if log.__contains__("[program is unsafe]"):
        assert spectector_result == "NA"
        spectector_result = "unsafe"
    if log.__contains__("{ERROR:"):
        assert spectector_result == "NA"
        spectector_result = "error"

    test_result = "NA"
    if source.__contains__("#![program is safe]"):
        if spectector_result == "safe":
            test_result = "success"
        if spectector_result == "unsafe":
            test_result = "failed"
    if source.__contains__("#![program is unsafe]"):
        if spectector_result == "safe":
            test_result = "failed"
        if spectector_result == "unsafe":
            test_result = "success"

    result = {
        "source": args.source,
        "spectector_result": spectector_result,
        "test_result": test_result,
    }

    with open(Path(args.output), "w") as output_file:
        yaml.dump(result, output_file)

if __name__ == '__main__':
    main()
