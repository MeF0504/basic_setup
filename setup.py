
import os
import argparse
import commands

def mkdir(path):
    path = os.path.expanduser(path)
    if not os.path.exists(path):
        print 'mkdir '+path
        os.mkdir(path)
        os.chmod(path,0755)

parser = argparse.ArgumentParser()
parser.add_argument('--prefix',help='install directory',default=os.path.expanduser('~/opt'))
parser.add_argument('--download',help='download some files (from git)',action='store_true')
args = parser.parse_args()

if not os.path.exists(args.prefix):
    print "install path %s does not exit" % args.prefix
    exit()

fpath = os.path.dirname(os.path.abspath(__file__))
binpath = os.path.join(args.prefix,'bin')
mkdir(binpath)
#print fpath
os.chdir(fpath)

############### python script directory ###############
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

############### basic setup directory ###############
setdir = os.path.join(fpath,'setup')
print '\n@ '+setdir+'\n'
files = ('zshrc_file','256colors.pl','ssh-host-color.sh','terminator_config')
for fy in files:
    spath = os.path.join(setdir,fy)
    if os.path.exists(spath):
        if 'zshrc_file' in spath:
            print 'copy %s --> ~/.zshrc' % os.path.basename(spath)
            os.system('cp -i %s ~/.zshrc' % spath)
            if not os.path.exists(os.path.expanduser('~/.zshrc.mine')):
                with open(os.path.expanduser('~/.zshrc.mine'),'a') as f:
                    print >> f,'## PC dependent zshrc'
                    print >> f,'#'
                    print >> f,'\n'

        if '256colors.pl' in spath:
            print 'copy %s --> %s' % (os.path.basename(spath),binpath)
            os.system('cp -i %s %s' % (spath,binpath))

        if ('ssh-host-color.sh' in spath) and (os.uname()[0]=='Darwin'):
            print 'copy %s --> %s' % (os.path.basename(spath),binpath)
            os.system('cp -i %s %s' % (spath,binpath))

        if ('terminator_config' in spath) and (os.uname()[0]=='Linux') and os.path.exists(os.path.expanduser('~/.config/terminator')):
            print 'copy %s --> ~/.config/terminator/config' % os.path.basename(spath)
            os.system('cp -i %s ~/.config/terminator/config' % spath)

############### vim setup directory ###############
vimdir = os.path.join(fpath,'vim')
print '\n@ '+vimdir+'\n'

files = ('vimrc_file','vimrc_color','vimrc_plugin','vimrc_neobundle','vimrc_neocomp')
mkdir('~/.vim')
mkdir('~/.vim/rcdir')

if args.download:
    mkdir('tmp')
    os.chdir(os.path.join(fpath,'tmp'))
    print 'clone neobundle'
    mkdir('~/.vim/bundle/')
    os.system('git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim')
    print '\nclone inkpot'
    os.system('git clone https://github.com/ciaranm/inkpot')
    os.system('cp -ri ./inkpot/colors ~/.vim')
    print '\nclone seiya'
    os.system('git clone https://github.com/miyakogi/seiya.vim')
    os.system('cp -ri ./seiya.vim/plugin ~/.vim')
    print '\nremove download tmp files'
    os.system('rm -rf %s' % os.path.join(fpath,'tmp','*'))
    os.chdir(fpath)

for fy in files:
    vpath = os.path.join(vimdir,fy)
    if os.path.exists(vpath):
        if 'vimrc_file' in vpath:
            print 'copy %s --> ~/.vimrc' % os.path.basename(vpath)
            os.system('cp -i %s ~/.vimrc' % vpath)
        if 'vimrc_color' in vpath:
            print 'copy %s --> ~/.vim/rcdir' % os.path.basename(vpath)
            os.system('cp -i %s ~/.vim/rcdir/.vimrc.color' % vpath)
        if 'vimrc_plugin' in vpath:
            print 'copy %s --> ~/.vim/rcdir' % os.path.basename(vpath)
            os.system('cp -i %s ~/.vim/rcdir/.vimrc.plugin' % vpath)
        if 'vimrc_neobundle' in vpath:
            print 'copy %s --> ~/.vim/rcdir' % os.path.basename(vpath)
            os.system('cp -i %s ~/.vim/rcdir/.vimrc.neobundle' % vpath)
        if 'vimrc_neocomp' in vpath:
            print 'copy %s --> ~/.vim/rcdir' % os.path.basename(vpath)
            os.system('cp -i %s ~/.vim/rcdir/.vimrc.neocomplcache' % vpath)

vim_mine = os.path.expanduser('~/.vim/rcdir/.vimrc.mine')
if not os.path.exists(vim_mine):
    with open(vim_mine,'a') as f:
        print >> f,'"" PC dependent vimrc'
        print >> f,'"'
        print >> f,'\n'

