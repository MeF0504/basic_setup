#! /usr/bin/env python3

import argparse
from pathlib import Path
import warnings
import shutil

import pyexiv2


def main(args):
    infile = Path(args.inputfile)
    if not infile.is_file():
        print(f'file {infile} does not exist.')
        return
    infile2 = infile.with_stem(infile.stem+'_2')
    shutil.copy2(infile, infile2)

    with pyexiv2.Image(str(infile2)) as img:
        meta = img.read_exif()
        pri_cmt = meta['Exif.Photo.UserComment']
        if len(pri_cmt) != 0:
            warnings.warn('Previous comments exist. Overwritten.')
            warnings.warn(pri_cmt)
        meta['Exif.Photo.UserComment'] = args.comment
        img.modify_exif(meta)
        print('Added!')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('inputfile')
    parser.add_argument('comment')
    args = parser.parse_args()
    main(args)
