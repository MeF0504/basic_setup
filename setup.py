
import os
import sys
import argparse
import subprocess
if float(sys.version[:3]) < 2.7:
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
try:
    pyfiles = subprocess.check_output('zsh -c "ls %s/*(.x)"' % pydir,shell=True).split('\n')
except AttributeError:
    pyfiles = commands.getoutput('zsh -c "ls %s/*(.x)"' % pydir).split('\n')

for p in pyfiles:
    #print 'p',p,'p'
    fname = os.path.basename(p)
    if p=="": continue
    elif os.path.exists(os.path.join(binpath,fname)):
        print fname+'\t is already exist, cannot link!'
        continue
    subprocess.call('ln -s %s %s' % (p,binpath),shell=True)
    print 'linked '+fname

############### basic setup directory ###############
setdir = os.path.join(fpath,'setup')
print '\n@ '+setdir+'\n'
files = ('zshrc_file','256colors.pl','ssh-host-color.sh','terminator_config')
for fy in files:
    spath = os.path.join(setdir,fy)
    if os.path.exists(spath):
        if 'zshrc_file' in spath:
            if os.path.exists(os.path.expanduser('~/.zshrc')):
                print '~/.zshrc\t is already exist, cannot link!'
            else:
                print 'linked %s --> ~/.zshrc' % os.path.basename(spath)
                #subprocess.call('cp -i %s ~/.zshrc' % spath,shell=True)
                subprocess.call('ln -s %s ~/.zshrc' % spath,shell=True)
            if not os.path.exists(os.path.expanduser('~/.zshrc.mine')):
                with open(os.path.expanduser('~/.zshrc.mine'),'a') as f:
                    print >> f,'## PC dependent zshrc'
                    print >> f,'#'
                    print >> f,'\n'

        if '256colors.pl' in spath:
            print '\ncopy %s --> %s' % (os.path.basename(spath),binpath)
            subprocess.call('cp -i %s %s' % (spath,binpath),shell=True)

        if ('ssh-host-color.sh' in spath) and (os.uname()[0]=='Darwin'):
            print '\ncopy %s --> %s' % (os.path.basename(spath),binpath)
            subprocess.call('cp -i %s %s' % (spath,binpath),shell=True)
            if not os.path.exists(os.path.expanduser('~/.ssh/ssh-host-color-set')):
                with open(os.path.expanduser('~/.ssh/ssh-host-color-set'),'a') as f:
                    print >> f,'hoge 10 10 25'
                    print >> f,'fuga 18 5 10'
                    print >> f,'bar 10 25 10'

        if ('terminator_config' in spath) and (os.uname()[0]=='Linux') and os.path.exists(os.path.expanduser('~/.config/terminator')):
            print '\ncopy %s --> ~/.config/terminator/config' % os.path.basename(spath)
            subprocess.call('cp -i %s ~/.config/terminator/config' % spath,shell=True)

############### vim setup directory ###############
vimdir = os.path.join(fpath,'vim')
print '\n@ '+vimdir+'\n'

files = ('vimrc_file','vimrc_color','vimrc_plugin','vimrc_neobundle')
mkdir('~/.vim')
mkdir('~/.vim/rcdir')

if args.download:
    mkdir('tmp')
    os.chdir(os.path.join(fpath,'tmp'))
    print '\nclone neobundle'
    mkdir('~/.vim/bundle/')
    subprocess.call('git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim',shell=True)
    print '\nclone inkpot'
    subprocess.call('git clone https://github.com/ciaranm/inkpot',shell=True)
    subprocess.call('cp -ri ./inkpot/colors ~/.vim',shell=True)
    print '\nclone seiya'
    subprocess.call('git clone https://github.com/miyakogi/seiya.vim',shell=True)
    subprocess.call('cp -ri ./seiya.vim/plugin ~/.vim',shell=True)
    print '\nremove download tmp files'
    subprocess.call('rm -rf %s' % os.path.join(fpath,'tmp','*'),shell=True)
    os.chdir(fpath)

for fy in files:
    vpath = os.path.join(vimdir,fy)
    if os.path.exists(vpath):

        if 'vimrc_file' in vpath:
            if os.path.exists(os.path.expanduser('~/.vimrc')):
                print '~/.vimrc\t is already exist, cannot link!'
            else:
                print 'linked %s --> ~/.vimrc' % os.path.basename(vpath)
                #subprocess.call('cp -i %s ~/.vimrc' % vpath,shell=True)
                subprocess.call('ln -s %s ~/.vimrc' % vpath,shell=True)

        if 'vimrc_color' in vpath:
            if os.path.exists(os.path.expanduser('~/.vim/rcdir/.vimrc.color')):
                print '.vimrc.color\t is already exist, cannot link!'
            else:
                print 'linked %s --> ~/.vim/rcdir' % os.path.basename(vpath)
                #subprocess.call('cp -i %s ~/.vim/rcdir/.vimrc.color' % vpath,shell=True)
                subprocess.call('ln -s %s ~/.vim/rcdir/.vimrc.color' % vpath,shell=True)

        if 'vimrc_plugin' in vpath:
            if os.path.exists(os.path.expanduser('~/.vim/rcdir/.vimrc.plugin')):
                print '.vimrc.plugin\t is already exist, cannot link!'
            else:
                print 'linked %s --> ~/.vim/rcdir' % os.path.basename(vpath)
                #subprocess.call('cp -i %s ~/.vim/rcdir/.vimrc.plugin' % vpath,shell=True)
                subprocess.call('ln -s %s ~/.vim/rcdir/.vimrc.plugin' % vpath,shell=True)

        if 'vimrc_neobundle' in vpath:
            if os.path.exists(os.path.expanduser('~/.vim/rcdir/.vimrc.neobundle')):
                print '.vimrc.neobundle\t is already exist, cannot link!'
            else:
                print 'linked %s --> ~/.vim/rcdir' % os.path.basename(vpath)
                #subprocess.call('cp -i %s ~/.vim/rcdir/.vimrc.neobundle' % vpath,shell=True)
                subprocess.call('ln -s %s ~/.vim/rcdir/.vimrc.neobundle' % vpath,shell=True)

vim_mine = os.path.expanduser('~/.vim/rcdir/.vimrc.mine')
if not os.path.exists(vim_mine):
    with open(vim_mine,'a') as f:
        print >> f,'"" PC dependent vimrc'
        print >> f,'"'
        print >> f,'\n'

