#! /usr/bin/env python

import os
import subprocess

def linux():
    release_files = ['/etc/redhat-release','/etc/lsb-release','/etc/issue']
    for rf in release_files:
        if os.path.exists(rf):
            #print subprocess.check_output('cat '+rf,shell=True)
            subprocess.call('cat '+rf,shell=True)
            exit()

def mac():
    #print subprocess.check_call('sw_vers',shell=True)
    subprocess.call('sw_vers',shell=True)
    exit()

uname = os.uname()[0]
if uname == 'Darwin':
    mac()
elif uname == 'Linux':
    linux()

else:
    print "can't find version file. please add version file place in version.py!"
