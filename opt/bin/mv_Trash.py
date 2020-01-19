#! /usr/bin/env python3

from send2trash import send2trash
import sys
import os.path as op

files = sys.argv[1:]

for fy in files:
    if op.exists(fy):
        send2trash(fy)
    else:
        print("[" + fy + "] not found.")

