
import os
import sys
import argparse
import subprocess
import glob
#if float(sys.version[:3]) < 2.7:
    #import commands


def mkdir(path):
    path = os.path.expanduser(path)
    if not os.path.exists(path):
        print 'mkdir '+path
        os.mkdir(path)
        os.chmod(path,0755)

def fcopy(file1,file2,link=False,**kwargs):
    name1 = os.path.basename(file1)
    name2 = os.path.basename(file2)
    if kwargs.has_key('condition'):
        condition = kwargs['condition']
    else:
        condition = True
    if link:
        if (not os.path.exists(file2)) and condition:
            subprocess.call('ln -s %s %s' % (file1,file2),shell=True)
            print 'linked '+name1
        elif condition:
            print name2+'\t is already exist, cannot link!'
    else:
        if (not os.path.exists(file2)) and condition:
            print 'copy %s --> %s\n' % (file1,file2)
            subprocess.call('cp %s %s' % (file1,file2),shell=True)
        elif condition:
            yn = raw_input(name2+'\t is already exist, are you realy overwite? [y,n]')
            if (yn == 'y') or (yn == 'yes'):
                print 'copy %s --> %s\n' % (file1,file2)
                subprocess.call('cp %s %s' % (file1,file2),shell=True)
            else:
                print 'Do not copy '+name2+'\n'

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix',help='install directory',default=os.path.expanduser('~/opt'))
    parser.add_argument('--download',help='download some files (from git)',action='store_true')
    parser.add_argument('--copy',help="only copy files instead of link",action='store_true')
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
    #try:
        #pyfiles = subprocess.check_output('zsh -c "ls %s/*(.x)"' % pydir,shell=True).split('\n')
    #except AttributeError:
        #pyfiles = commands.getoutput('zsh -c "ls %s/*(.x)"' % pydir).split('\n')
    pyfiles = []
    for pfy in glob.glob(os.path.join(pydir,'*')):
        if os.access(pfy,os.X_OK):
            pyfiles.append(pfy)

    for p in pyfiles:
        #print 'p',p,'p'
        fname = os.path.basename(p)
        fcopy(p,os.path.join(binpath,fname),link=True)

    ############### basic setup directory ###############
    setdir = os.path.join(fpath,'setup')
    print '\n@ '+setdir+'\n'
    files = {'zshrc_file':'~/.zshrc','256colors.pl':'256colors.pl','ssh-host-color.sh':'ssh-host-color.sh','terminator_config':'terminator_config'}
    for fy in files:
        spath = os.path.join(setdir,fy)
        if os.path.exists(spath):
            if 'zshrc_file' in spath:
                fcopy(spath,os.path.expanduser(files[fy]),link=bool(1-args.copy))
                if not os.path.exists(os.path.expanduser('~/.zshrc.mine')):
                    with open(os.path.expanduser('~/.zshrc.mine'),'a') as f:
                        print >> f,'## PC dependent zshrc'
                        print >> f,'#'
                        print >> f,'\n'

            if '256colors.pl' in spath:
                fcopy(spath,os.path.join(binpath,files[fy]))

            if 'ssh-host-color.sh' in spath:
                fcopy(spath,os.path.join(binpath,files[fy]),link=False,condition=os.uname()[0]=='Darwin')
                if not os.path.exists(os.path.expanduser('~/.ssh/ssh-host-color-set')):
                    with open(os.path.expanduser('~/.ssh/ssh-host-color-set'),'a') as f:
                        print >> f,'hoge 10 10 25'
                        print >> f,'fuga 18 5 10'
                        print >> f,'bar 10 25 10'

            if ('terminator_config' in spath):
                fcopy(spath,os.path.expanduser(files[fy]),link=False,condition=((os.uname()[0]=='Linux') and os.path.exists(os.path.expanduser('~/.config/terminator'))))

    ############### vim setup directory ###############
    vimdir = os.path.join(fpath,'vim')
    print '\n@ '+vimdir+'\n'

    files = {'vimrc_file':'~/.vimrc','vimrc_color':'.vimrc.color','vimrc_plugin':'.vimrc.plugin','vimrc_neobundle':'.vimrc.neobundle'}
    mkdir('~/.vim')
    mkdir('~/.vim/rcdir')
    rcdir = os.path.expanduser('~/.vim/rcdir')

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
        print '\nclone quickrun'
        subprocess.call('git clone https://github.com/thinca/vim-quickrun.git',shell=True)
        subprocess.call('cp -ri ./vim-quickrun/plugin/quickrun.vim ~/.vim/plugin/',shell=True)
        print '\nremove download tmp files'
        subprocess.call('rm -rf %s' % os.path.join(fpath,'tmp','*'),shell=True)
        os.chdir(fpath)

    for fy in files:
        vpath = os.path.join(vimdir,fy)
        if os.path.exists(vpath):

            if 'vimrc_file' in vpath:
                fcopy(vpath,os.path.expanduser(files[fy]),link=bool(1-True))

            else:
                fcopy(vpath,os.path.join(rcdir,files[fy]),link=bool(1-True))

    vim_mine = os.path.expanduser('~/.vim/rcdir/.vimrc.mine')
    if not os.path.exists(vim_mine):
        with open(vim_mine,'a') as f:
            print >> f,'"" PC dependent vimrc'
            print >> f,'"'
            print >> f,'\n'

