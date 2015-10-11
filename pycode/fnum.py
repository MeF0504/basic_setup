#! /usr/bin/env python

import sys
import commands

if len(sys.argv) < 2:
    wd = '.'
else:
    wd = sys.argv[1]
files = int(commands.getoutput("ls -l %s | wc -l" % wd))

if len(sys.argv) > 2:
    files = len(sys.argv)

print files-1

