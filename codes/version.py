#! /usr/bin/env python

import os
import sys
import subprocess

def linux_version():
    release_files = ['/etc/redhat-release','/etc/lsb-release','/etc/issue']
    for rf in release_files:
        if os.path.exists(rf):
            #print subprocess.check_output('cat '+rf,shell=True)
            subprocess.call('cat '+rf,shell=True)
            exit()

def linux_cpu():
    subprocess.call('cat /proc/cpuinfo', shell=True)
    
def linux_mem():
    subprocess.call('cat /proc/meminfo', shell=True)


def mac_version():
    #print subprocess.check_call('sw_vers',shell=True)
    subprocess.call('sw_vers',shell=True)

def mac_cpu():
    subprocess.call('system_profiler SPHardwareDataType', shell=True)

def mac_mem():
    subprocess.call('system_profiler SPHardwareDataType', shell=True)


if __name__ == "__main__":
    uname = os.uname()[0]
    if (len(sys.argv) <= 1) or (sys.argv[1] == "version"):
        if uname == 'Darwin':
            mac_version()
        elif uname == 'Linux':
            linux_version()
        else:
            print("can't find version file. please add version file place in version.py!")

    elif sys.argv[1] == "cpu":
        if uname == 'Darwin':
            mac_cpu()
        elif uname == 'Linux':
            linux_cpu()
        else:
            print("can't find cpu file. please add version file place in version.py!")

    elif sys.argv[1] == "memory":
        if uname == 'Darwin':
            mac_mem()
        elif uname == 'Linux':
            linux_mem()
            print("can't find memory file. please add version file place in version.py!")

    elif sys.argv[1] == "all":
        if uname == 'Darwin':
            mac_version()
            mac_cpu()
        elif uname == 'Linux':
            linux_version()
            linux_cpu()
            linux_mem()

    else:
        print("""
usage: version.py [command]

enable commands are following;
version : display version.
cpu     : display cpu information.
memory  : display memory information.
all     : display version, cpu, and memory information.
""")

