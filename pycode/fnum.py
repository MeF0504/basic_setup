#! /usr/bin/env python

import sys
import subprocess
if float(sys.version[:3]) < 2.7:
    import commands

if len(sys.argv) < 2:
    wd = '.'
else:
    wd = sys.argv[1]
try:
    files = int(subprocess.check_output('ls -l %s | wc -l' % wd,shell=True))
except AttributeError:
    files = int(commands.getoutput('ls -l %s | wc -l' % wd,shell=True))

if len(sys.argv) > 2:
    files = len(sys.argv)

print files-1

