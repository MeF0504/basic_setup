#! /usr/bin/env python3
# copy util
# copy ifles with date, compare files, ...

import os
from datetime import datetime
import argparse
import shutil
from pathlib import Path
import filecmp


def grabargs():
    parser = argparse.ArgumentParser(description='multipurpose file-copying script')
    parser.add_argument('source_dir', help="source directory")
    parser.add_argument('target_dir', help="target directory")
    parser.add_argument('--cmp', help='compare each file and skip copy if source and target file are same.', action='store_true')
    parser.add_argument('--all', help='copy hidden files.',
                        action='store_true')
    parser.add_argument('--test', help='show which files will be copied.',
                        action='store_true')
    opt_type = parser.add_mutually_exclusive_group()
    opt_type.add_argument('--date', help="copy files in the source directory to target_dir/{date}. you can specify -c, -n, -m amd -a. -c is the default.",
                          action='store_true')
    opt_type.add_argument('-r', '--recursive', help="copy files recursively.",
                          action='store_true')
    dt_type = parser.add_mutually_exclusive_group()
    dt_type.add_argument('-c', help='(date) meta data update (UNIX), created (Windows)',
                         action='store_true')
    dt_type.add_argument('-b', help='(date) created (some OS)',
                         action='store_true')
    dt_type.add_argument('-m', help='(date) last update', action='store_true')
    dt_type.add_argument('-a', help='(date) last access', action='store_true')

    args = parser.parse_args()
    return args


def main():
    args = grabargs()

    s_dir = Path(args.source_dir)
    t_dir = Path(args.target_dir)

    if args.recursive:
        s_files = s_dir.glob('**/*')
    else:
        s_files = s_dir.glob('*')

    for s_file in s_files:
        if not s_file.is_file():
            continue
        if not args.all and s_file.name.startswith('.'):
            continue

        if args.date:
            if args.c:
                dt = datetime.fromtimestamp(s_file.stat().st_ctime)
            elif args.b:
                dt = datetime.fromtimestamp(s_file.stat().st_birthtime)
            elif args.m:
                dt = datetime.fromtimestamp(s_file.stat().st_mtime)
            elif args.a:
                dt = datetime.fromtimestamp(s_file.stat().st_atime)
            else:
                dt = datetime.fromtimestamp(s_file.stat().st_ctime)
            dir_name = "%4d-%02d-%02d" % (dt.year, dt.month, dt.day)
            dir_name = t_dir/dir_name
        elif args.recursive:
            dir_name = s_file.parent.relative_to(s_dir)
            dir_name = t_dir/dir_name
        else:
            dir_name = t_dir

        if not dir_name.is_dir() and not args.test:
            os.makedirs(dir_name)

        t_file = dir_name/s_file.name

        is_copy = False
        if not t_file.is_file():
            is_copy = True
        elif args.cmp:
            if not filecmp.cmp(s_file, t_file):
                # not same file.
                is_copy = True

        if is_copy:
            if args.test:
                print(f"[test] copy {s_file} -> {t_file}")
            else:
                print(f"copy {t_file}")
                shutil.copy(s_file, t_file)


if __name__ == "__main__":
    main()
