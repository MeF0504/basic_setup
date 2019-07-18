#! /usr/bin/env python3

from send2trash import send2trash
import sys

files = sys.argv[1:]

for fy in files:
    send2trash(fy)

