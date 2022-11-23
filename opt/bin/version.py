#! /usr/bin/env python3

import os
import subprocess
import argparse

try:
    from local_lib_color import BG, END
    bg = BG['c']
except ImportError:
    bg = ''
    END = ''


def linux_version():
    release_files = ['/etc/redhat-release', '/etc/lsb-release',
                     '/etc/lsb-release', '/etc/oracle-release',
                     '/etc/os-release', '/etc/system-release', '/etc/issue']
    found_file = False
    for rf in release_files:
        if os.path.exists(rf):
            with open(rf, 'r') as f:
                for line in f:
                    print(line, end='')
            found_file = True
            break
    if not found_file:
        print('any release file is not found.')


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
    subprocess.call('sw_vers', shell=True)


def mac_cpu():
    subprocess.call('system_profiler SPHardwareDataType', shell=True)


def mac_mem():
    subprocess.call('system_profiler SPHardwareDataType', shell=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='show version etc. information of this computer.')
    parser.add_argument('-v', '--version', help='display version.',
                        action='store_true')
    parser.add_argument('-c', '--cpu', help='display CPU information.',
                        action='store_true')
    parser.add_argument('-m', '--memory', help='display memory information.',
                        action='store_true')
    parser.add_argument('-a', '--all', help='display all information.',
                        action='store_true')
    args = parser.parse_args()

    uname = os.uname()[0]
    show_contents = []
    if args.version:
        show_contents += ['v']
    if args.cpu:
        show_contents += ['c']
    if args.memory:
        show_contents += ['m']
    if args.all:
        show_contents = ['v', 'c', 'm']

    if uname == 'Darwin':
        if 'v' in show_contents:
            print("{}----------OS version----------{}".format(bg, END))
            mac_version()
        if 'c' in show_contents or 'm' in show_contents:
            print("{}----------cpu & memory information----------{}".format(
                bg, END))
            mac_cpu()
    elif uname == 'Linux':
        if 'v' in show_contents:
            print("{}----------OS version----------{}".format(bg, END))
            linux_version()
        if 'c' in show_contents:
            print("{}----------cpu  information----------{}".format(bg, END))
            linux_cpu()
        if 'm' in show_contents:
            print("{}----------memory information----------{}".format(bg, END))
            linux_mem()
    else:
        print('Sorry, this OS is not supported.')
