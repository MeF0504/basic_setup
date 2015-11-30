#! /usr/bin/env python

import subprocess
import sys

if len(sys.argv) != 2 or not sys.argv[-1].startswith('/'):
    print 'please input enviromental variable'

else:
    envar = subprocess.check_output('echo %s' % sys.argv[1],shell=True)
    envar = envar.replace(':',':\n')

    print envar


