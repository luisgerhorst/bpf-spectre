#!/usr/bin/env python3

import argparse
import shutil
import sys
from pathlib import Path
import yaml # pyaml
import logging
import string
import pandas as pd

def parseargs():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=str)
    parser.add_argument('--yamls', type=str, nargs='+')
    return parser.parse_args()

def main():
    logging.basicConfig(level=logging.DEBUG)
    args = parseargs()

    dfs = []

    # Sort tests to allow for easier debugging.
    for yaml_path in sorted(args.yamls):
        df = yaml_path_to_df(yaml_path)
        dfs.append(df)

    df = pd.concat(dfs)

    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(Path(args.output), sep="\t", index=False)

def yaml_path_to_df(yaml_path):
    df = pd.DataFrame()
    with open(yaml_path) as yaml_file:
        obj = yaml.safe_load(yaml_file)
        return yaml_to_df(obj)

def yaml_to_df(value):
    df = pd.DataFrame({})
    for subkey, subvalue in value.items():
        # logging.info(f'{subkey} = {subvalue}, {df}')
        df = yaml_field_to_df(df, subkey, subvalue)
    return df

def yaml_field_to_df(df, prefix, value):
    sep = "_"
    if isinstance(value, dict):
        for subkey, subvalue in value.items():
            df = yaml_field_to_df(df, prefix + sep + subkey, subvalue)
    elif isinstance(value, list):
        for i, subvalue in enumerate(value):
            df = yaml_field_to_df(df, prefix + sep + str(i), subvalue)
        df[prefix] = " ".join(map(str, value))
    else:
        df[prefix] = [value]
    return df


if __name__ == '__main__':
    main()
