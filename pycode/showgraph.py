#! /usr/bin/env python

import os
import sys
import glob

try:
    files = sys.argv[1:]
except:
    files = glob.glob("./*.png").sort()

#print files

for f in files:
    judge = os.system("display %s" % f)

    if judge != 0:
        break


