#! /usr/bin/env python3

import argparse
from pathlib import Path

import pyexiv2


def main(args):
    infile = Path(args.inputfile)
    if not infile.is_file():
        print(f'file {infile} does not exist.')
        return

    img = pyexiv2.Image(infile)
    meta = img.read_exif()
    for k, v in meta.items():
        print(k, v)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('inputfile')
    parser.add_argument('comment')
    args = parser.parse_args()
    main(args)
