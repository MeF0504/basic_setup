#! /usr/bin/env python

import os
import sys
import glob

def linux():
    for f in files:
        #judge = os.system("display %s" % f)
        if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.PNG') or f.endswith('.JPG') or f.endswith('.MIFF'):
            judge = os.system('display %s' % f)
        elif f.endswith('.pdf') or f.endswith('.PDF'):
            judge = os.system('evince %s' % f)
        else:
            continue

        if judge != 0:
            break

def mac():
    f2 = ''
    for f in files:
        if f.endswith('.png') or f.endswith('.jpg') or f.endswith('.PNG') or f.endswith('.JPG') or f.endswith('.MIFF') or f.endswith('.pdf') or f.endswith('.PDF'):
            f2 += ' '+f

    #print f2
    os.system('open -a Preview '+f2)


try:
    files = sys.argv[1:]
except:
    files = glob.glob("./*").sort()

#print files

if os.uname()[0] == 'Linux': linux()
if os.uname()[0] == 'Darwin': mac()
