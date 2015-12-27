#! /usr/bin/env python

import sys
import os
import glob
import subprocess
#if float(sys.version[:3]) < 2.7:
    #import commands

def len1(wd):
    wd = os.path.join(wd,'*')
    return len(glob.glob(wd))

if len(sys.argv) < 2:
    wd = '.'
    files = len1(wd)
else:
    wd = sys.argv[1]
#try:
    #files = int(subprocess.check_output('ls -l %s | wc -l' % wd,shell=True))
#except AttributeError:
    #files = int(commands.getoutput('ls -l %s | wc -l' % wd))
    files = len1(wd)

if len(sys.argv) > 2:
    files = len(sys.argv)
    files -= 1

print files

