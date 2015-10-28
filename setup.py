
import os
import argparse
import commands

parser = argparse.ArgumentParser()
parser.add_argument('--prefix',help='install directory',default='$HOME/opt')
args = parser.parse_args()

if not os.path.exists(args.prefix):
    print "install path does'nt exit"
    exit()

fpath = os.path.dirname(os.path.abspath(__file__))
binpath = os.path.join(args.prefix,'bin')
#print fpath

pydir = os.path.join(fpath,'pycode')
print '@ '+pydir
pyfiles = commands.getoutput('ls -l %s/' % pydir).split('\n')

for p in pyfiles:
    if p[3] == 'x':
        p = p.split(' ')
        fname = os.path.basename(p[-1])
        if os.path.exists(os.path.join(binpath,fname)):
            print fname+'is already exist, cannot link!'
            continue
        #print p[-1],binpath
        os.system('ln -s %s %s' % (p[-1],binpath))
