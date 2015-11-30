#! /usr/bin/env python

import os
import subprocess
import sys
import glob

def linux():
    for f in files:
        #judge = os.system("display %s" % f)
        if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.PNG') or f.endswith('.JPG') or f.endswith('.MIFF'):
            judge = subprocess.call('display %s' % f,shell=True)
        elif f.endswith('.pdf') or f.endswith('.PDF'):
            judge = subprocess.call('evince %s' % f,shell=True)
        else:
            continue

        if judge != 0:
            break

def mac():
    f2 = ''
    for f in files:
        if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.PNG') or f.endswith('.JPG') or f.endswith('.MIFF') or f.endswith('.pdf') or f.endswith('.PDF'):
            f = f.replace(' ','\ ')
            f2 += ' '+f

    #print f2
    subprocess.call('open -a Preview '+f2,shell=True)


if len(sys.argv) != 1:
    files = sys.argv[1:]
else:
    files = glob.glob("./*")
    files.sort()

#print files,'\n'

if os.uname()[0] == 'Linux': linux()
if os.uname()[0] == 'Darwin': mac()

