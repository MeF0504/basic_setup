#! /usr/bin/env python

import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('environ',help='environment value')
args = parser.parse_args()

if ':' in args.environ:
    envar = args.environ
    envar = envar.replace(':',':\n')
    print envar
    exit()

try:
    envar = os.environ[args.environ]
    envar = envar.replace(':',':\n')
    print envar

except KeyError:
    print 'please input environmental variable'

