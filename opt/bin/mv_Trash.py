#! /usr/bin/env python3

from send2trash import send2trash
import sys
import os

files = sys.argv[1:]

for fy in files:
    if os.path.exists(fy):
        os.utime(fy)    # update time stamp
        send2trash(fy)
    else:
        print("[" + fy + "] not found.")

