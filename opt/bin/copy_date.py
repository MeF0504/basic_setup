#! /usr/bin/env python3
# coding: utf-8
# Playmemories Homeの代わり。
# fileの作成日ごとにファイルを作成する。

import os
from datetime import datetime
import argparse
import shutil
from pathlib import Path


def grabargs():
    parser = argparse.ArgumentParser(description = "copy files in the source directory to target_dir/{date}. The date is the creation time (-c option) by default, but you can specify the type using the '-c', -b', '-m', or '-a' option.")
    parser.add_argument('source_dir', help="source directory")
    parser.add_argument('target_dir', help="target directory")
    dt_type = parser.add_mutually_exclusive_group()
    dt_type.add_argument('-c', help='meta data update (UNIX), created (Windows)', action='store_true')
    dt_type.add_argument('-b', help='created (some OS)', action='store_true')
    dt_type.add_argument('-m', help='last update', action='store_true')
    dt_type.add_argument('-a', help='last access', action='store_true')

    args = parser.parse_args()
    return args


def main():
    args = grabargs()

    s_dir = Path(args.source_dir)
    t_dir = Path(args.target_dir)

    for fy in s_dir.glob('*'):
        if args.c:
            dt = datetime.fromtimestamp(fy.stat().st_ctime)
        elif args.b:
            dt = datetime.fromtimestamp(fy.stat().st_birthtime)
        elif args.m:
            dt = datetime.fromtimestamp(fy.stat().st_mtime)
        elif args.a:
            dt = datetime.fromtimestamp(fy.stat().st_atime)
        else:
            dt = datetime.fromtimestamp(fy.stat().st_ctime)
        dir_name = "%4d-%02d-%02d" % (dt.year, dt.month, dt.day)
        dir_name = t_dir/dir_name
        if not dir_name.is_dir():
            os.makedirs(dir_name)

        t_file = dir_name/fy.name
        if not t_file.is_file():
            print("copy %s" % t_file)
            shutil.copy(fy, t_file)


if __name__ == "__main__":
    main()
