#! /usr/bin/env python

import subprocess
import sys
if float(sys.version[:3]) < 2.7:
    import commands

if len(sys.argv) != 2 or not sys.argv[-1].startswith('/'):
    print 'please input enviromental variable'

else:
    try: envar = subprocess.check_output('echo %s' % sys.argv[1],shell=True)
    except AttributeError:
        envar = commands.getoutput('echo %s' % sys.argv[1])
    envar = envar.replace(':',':\n')

    print envar


