#! /usr/bin/env python3

import os
import sys
import subprocess

if os.getcwd() != "{}":
    print('cd {}')
    os.chdir("{}")

if not (len(sys.argv) >= 2 and sys.argv[1] == '--nopull'):
    print('pull...')
    stat = subprocess.run(['git', 'pull'])
    if stat.returncode != 0:
        exit()

if input('update? (y/[n]) ') == 'y':
    stat = subprocess.run('python3 setup.py {}', shell=True)
