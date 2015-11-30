#! /usr/bin/env python

import sys
import subprocess

if len(sys.argv) < 2:
    wd = '.'
else:
    wd = sys.argv[1]
files = int(subprocess.check_output('ls -l %s | wc -l' % wd,shell=True))

if len(sys.argv) > 2:
    files = len(sys.argv)

print files-1

