#! /usr/bin/env python3

import os
import subprocess
import argparse

try:
    from local_lib_color import BG, FG, END
    bg = BG['c']
except ImportError as e:
    bg = ''
    END = ''

def linux_version():
    release_files = ['/etc/redhat-release','/etc/lsb-release','/etc/issue']
    for rf in release_files:
        if os.path.exists(rf):
            with open(rf, 'r') as f:
                for line in f:
                    print(line, end='')
            break

def linux_cpu():
    cpuinfo = '/proc/cpuinfo'
    if not os.path.exists(cpuinfo):
        print('info file {} is not exists'.format(cpuinfo))
        return
    with open(cpuinfo, 'r') as f:
        for line in f:
            print(line, end='')

def linux_mem():
    meminfo = '/proc/meminfo'
    if not os.path.exists(meminfo):
        print('info file {} is not exists'.format(meminfo))
        return
    with open(meminfo, 'r') as f:
        for line in f:
            print(line, end='')


def mac_version():
    subprocess.call('sw_vers',shell=True)

def mac_cpu():
    subprocess.call('system_profiler SPHardwareDataType', shell=True)

def mac_mem():
    subprocess.call('system_profiler SPHardwareDataType', shell=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='show version etc. information of this computer.')
    parser.add_argument('-v', '--version', help='display version.', action='store_true')
    parser.add_argument('-c', '--cpu', help='display CPU information.', action='store_true')
    parser.add_argument('-m', '--memory', help='display memory information.', action='store_true')
    parser.add_argument('-a', '--all', help='display all information.', action='store_true')
    args = parser.parse_args()

    uname = os.uname()[0]
    is_display = False

    if args.version:
        is_display = True
        if uname == 'Darwin':
            mac_version()
        elif uname == 'Linux':
            linux_version()
        else:
            print('Sorry, this OS is not supported.')
    if args.cpu:
        is_display = True
        if uname == 'Darwin':
            mac_cpu()
        elif uname == 'Linux':
            linux_cpu()
        else:
            print('Sorry, this OS is not supported.')
    if args.memory:
        is_display = True
        if uname == 'Darwin':
            mac_mem()
        elif uname == 'Linux':
            linux_mem()
        else:
            print('Sorry, this OS is not supported.')
    if args.all:
        is_display = True
        if uname == 'Darwin':
            print("{}----------OS version----------{}".format(bg, END))
            mac_version()
            print("{}----------cpu & memory information----------{}".format(bg, END))
            mac_cpu()
        elif uname == 'Linux':
            print("{}----------OS version----------{}".format(bg, END))
            linux_version()
            print("{}----------cpu  information----------{}".format(bg, END))
            linux_cpu()
            print("{}----------memory information----------{}".format(bg, END))
            linux_mem()
        else:
            print('Sorry, this OS is not supported.')

    if not is_display:
        if uname == 'Darwin':
            mac_version()
        elif uname == 'Linux':
            linux_version()
        else:
            print('Sorry, this OS is not supported.')

