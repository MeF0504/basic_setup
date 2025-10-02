#! /usr/bin/env python3

from send2trash import send2trash
import sys
import os

files = sys.argv[1:]

for fy in files:
    if os.path.exists(fy):
        os.utime(fy)    # update time stamp
        if fy.endswith('/'):
            # If a directory ends with '/',
            # the name is not shown in the Trash in Linux?
            fy = fy[:-1]
        send2trash(fy)
    else:
        print("[" + fy + "] not found.")
