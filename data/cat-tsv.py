#!/usr/bin/env python3

import sys
import os
from pathlib import Path
import logging
import argparse
import glob
import re
import json

import numpy as np
import pandas as pd
import yaml

def main():
    parser = argparse.ArgumentParser(description="Concat tidy benchmark data.")
    parser.add_argument("-i", "--input", type=str, nargs='+', action='append')
    parser.add_argument("-o", "--output")
    args = parser.parse_args()

    df = pd.concat(map(lambda p: pd.read_csv(Path(p), sep='\t'), args.input[0]))

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output, sep="\t", index=False)

if __name__ == "__main__":
    main()
