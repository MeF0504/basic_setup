#! /usr/bin/env python

import os
import commands

def linux():
    if os.path.exists('/etc/redhat-release'):
        print commands.getoutput('cat /etc/redhat-release')
        exit()

    elif os.path.exists('/etc/lsb-release'):
        print commands.getoutput('cat /etc/lsb-release')
        exit()

    elif os.path.exists('/etc/issue'):
        print commands.getoutput('cat /etc/issue')
        exit()

    else:
        #version =  "can't find version file. please add version file place in version.py!"
        return

def mac():
    print commands.getoutput('sw_vers')
    exit()

uname = commands.getoutput('uname')
if uname == 'Darwin':
    mac()
elif uname == 'Linux':
    linux()

else:
    print "can't find version file. please add version file place in version.py!"
