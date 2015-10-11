#! /usr/bin/env python

import commands
import sys

if len(sys.argv) != 2 or not sys.argv[-1].startswith('/'):
    print 'please input enviromental variable'

else:
    envar = commands.getoutput('echo %s' % sys.argv[1])
    envar = envar.replace(':',':\n')

    print envar


