#! /usr/bin/env python3

import os
import glob
import shutil
import argparse
import datetime


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('dir', help='top directory of remove files/directories.')
    parser.add_argument('-v', dest='verbose', help='verbose output.', action='store_true')
    parser.add_argument('-d', dest='day', help='days until deletion.', type=int, default=30)
    args = parser.parse_args()
    return args

def main(args):
    top_dir = os.path.expandvars(args.dir)
    top_dir = os.path.expanduser(args.dir)
    tdy = datetime.datetime.today()

    # if args.verbose:
    #     print('remove following files.')
    files = glob.glob(os.path.join(top_dir, '*'))
    rm_files = []
    for fy in files:
        file_stat = os.stat(fy)
        dt = datetime.datetime.fromtimestamp(file_stat.st_ctime)

        if (tdy - dt).days > args.day:
            if args.verbose:
                print(' - {} [{}/{}]'.format(os.path.basename(fy), dt.month, dt.day))
            rm_files.append(fy)

    if len(rm_files) == 0:
        return

    if args.verbose:
        yn = input('remove? (y/[n])')
    else:
        yn = 'y'
    if (yn == 'y') or (yn == 'yes'):
        for fy in rm_files:
            if os.path.isfile(fy):
                os.remove(fy)
            else:
                shutil.rmtree(fy)

if __name__ == '__main__':
    args = get_args()
    main(args)

