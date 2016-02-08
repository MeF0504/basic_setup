#! /usr/bin/env python

import sys
import os
import glob
import argparse

def len1(wd):
    wd = os.path.join(wd,'*')
    return len(glob.glob(wd))

def len2(wd):
    wd = os.path.join(wd,'.*')
    return len(glob.glob(wd))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('files',help='target files and directories',nargs='*')
    parser.add_argument('-a','--all',help='Include directory entries whose names begin with a dot',action='store_true')
    args = parser.parse_args()

    if len(args.files) == 0:
        wd = '.'
        lenfile = len1(wd)
        if args.all:
            lenfile += len2(wd)
    elif len(args.files)==1 and os.path.isdir(args.files[0]):
        wd = args.files[0]
        lenfile = len1(wd)
        if args.all:
            lenfile += len2(wd)
    else:
        lenfile = len(args.files)

    print lenfile

