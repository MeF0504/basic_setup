#! /usr/bin/env python
# coding: utf-8
# Playmemories Homeの代わり。
# fileの作成日ごとにファイルを作成する。

from __future__ import print_function

import os
import os.path as op
import datetime
import argparse
import glob
import shutil

def grabargs():
    parser = argparse.ArgumentParser(description="copy files in source directory to date name directories in target directory")
    parser.add_argument('source_dir', help="source directory")
    parser.add_argument('target_dir', help="target directory")

    args = parser.parse_args()
    return args

def main():
    args = grabargs()

    s_dir = op.expanduser(args.source_dir)
    t_dir = op.expandvars(args.target_dir)

    for fy in glob.glob(op.join(s_dir, '*')):
        # 作成日時
        dt = datetime.datetime.fromtimestamp(os.stat(fy).st_ctime)
        # 更新日時はこっち
        # dt = datetime.datetime.fromtimestamp(os.stat(fy).st_mtime)
        dir_name = "%4d-%02d-%02d" % (dt.year, dt.month, dt.day)
        dir_name = op.join(t_dir, dir_name)
        if not op.exists(dir_name):
            os.makedirs(dir_name)

        t_file = op.join(dir_name, op.basename(fy))
        if not op.exists(t_file):
            print("copy %s" % t_file)
            shutil.copy(fy,t_file)
    
if __name__ == "__main__":
    main()
