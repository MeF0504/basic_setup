
import os
import argparse
import commands

parser = argparse.ArgumentParser()
parser.add_argument('--prefix',help='install directory',default=os.path.expanduser('~/opt'))
args = parser.parse_args()

if not os.path.exists(args.prefix):
    print "install path %s does not exit" % args.prefix
    exit()

fpath = os.path.dirname(os.path.abspath(__file__))
binpath = os.path.join(args.prefix,'bin')
if not os.path.exists(binpath):
    os.mkdir(binpath)
#print fpath
os.chdir(fpath)

pydir = os.path.join(fpath,'pycode')
print '\n@ '+pydir+'\n'
#pyfiles = commands.getoutput('ls -l %s/*' % pydir).split('\n')
pyfiles = commands.getoutput('zsh -c "ls %s/*(.x)"' % pydir).split('\n')

for p in pyfiles:
    #print p
    fname = os.path.basename(p)
    if os.path.exists(os.path.join(binpath,fname)):
        print fname+' is already exist, cannot link!'
        continue
    os.system('ln -s %s %s' % (p,binpath))
    print 'linked '+fname

setdir = os.path.join(fpath,'setup')
print '\n@ '+setdir+'\n'
setfiles = ('zshrc_file','256colors.pl','ssh-host-color.sh','terminator_config')
for fy in setfiles:
    fpath = os.path.join(setdir,fy)
    if os.path.exists(fpath):
        if 'zshrc_file' in fpath:
            print 'copy '+os.path.basename(fpath)
            os.system('cp -i %s ~/.zshrc' % fpath)
            if not os.path.exists(os.path.expanduser('~/.zshrc.mine')):
                with open(os.path.expanduser('~/.zshrc.mine'),'a') as f:
                    print >> f,'## PC dependent zshrc'
                    print >> f,'#'
                    print >> f,'\n'

        if '256colors.pl' in fpath:
            print 'copy '+os.path.basename(fpath)
            os.system('cp -i %s %s' % (fpath,binpath))

        if ('ssh-host-color.sh' in fpath) and (os.uname()[0]=='Darwin'):
            print 'copy '+os.path.basename(fpath)
            os.system('cp -i %s %s' % (fpath,binpath))

        if ('terminator_config' in fpath) and (os.uname()[0]=='Linux') and os.path.exists(os.path.expanduser('~/.config/terminator')):
            print 'copy '+os.path.basename(fpath)
            os.system('cp -i %s ~/.config/terminator/config' % fpath)

