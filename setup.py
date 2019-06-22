
import os
import os.path as op
import argparse
import subprocess
import glob
#if float(sys.version[:3]) < 2.7:
    #import commands


def mkdir(path):
    path = op.expanduser(path)
    if not op.exists(path):
        print 'mkdir '+path
        os.makedirs(path, mode=0o755)
        #os.chmod(path,0755)

def fcopy(file1,file2,link=False,force=False,**kwargs):
    def fcopy_main(cmd,comment,test):
        if not test:
            subprocess.call(cmd, shell=True)
            print comment
        else:
            print 'cmd check:: '+cmd+'\n'

    name1 = op.basename(file1)
    name2 = op.basename(file2)

    if kwargs.has_key('test'):
        test = kwargs['test']
    else:
        test = False

    if kwargs.has_key('condition'):
        condition = kwargs['condition']
    else:
        condition = True

    if link:    #link
        cmd = 'ln -s %s %s' % (file1, file2)
        comment = 'linked '+name1

        if (not op.exists(file2)) and condition:
            fcopy_main(cmd,comment,test)
        elif condition:
            print '[  %s  ] is already exist, cannot link!' % name2

    else:       #copy
        cmd = 'cp %s %s' % (file1, file2)
        comment = 'copy %s --> %s\n' % (name1,file2)

        if force and condition:
            fcopy_main(cmd, comment, test)
        elif (not op.exists(file2)) and condition:
            fcopy_main(cmd, comment, test)
        elif condition:
            yn = raw_input('[  %s  ] is already exist, are you realy overwite? [y,n]' % name2)
            if (yn == 'y') or (yn == 'yes'):
                fcopy_main(cmd, comment, test)
            else:
                print 'Do not copy '+name2+'\n'

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix',help='install directory',default=op.expanduser('~/opt'))
    parser.add_argument('--download',help='download some files (from git)',action='store_true')
    parser.add_argument('--link',help="link files instead of copy",action='store_true')
    parser.add_argument('--test',help="don't copy, just show command",action='store_true')
    parser.add_argument('-f','--force',help="Do not prompt for confirmation before overwriting the destination path",action='store_true')
    args = parser.parse_args()

    #print dir(args)
    #exit()
    if not op.exists(args.prefix):
        print "install path %s does not exit" % args.prefix
        exit()

    fpath = op.dirname(op.abspath(__file__))
    binpath = op.join(args.prefix,'bin')
    mkdir(binpath)
    #print fpath
    os.chdir(fpath)

    ############### script directory ###############
    codedir = op.join(fpath,'codes')
    print '\n@ '+codedir+'\n'
    codefiles = []
    for cfy in glob.glob(op.join(codedir,'*')):
        if os.access(cfy,os.X_OK):
            if (op.basename(cfy) == 'ssh-host-color.ssh'):
                if (os.uname()[0] =='Darwin'):
                    codefiles.append(cfy)
            elif (op.basename(cfy) == 'pdf2jpg'):
                if (os.uname()[0] == 'Darwin'):
                    codefiles.append(cfy)
            else:
                codefiles.append(cfy)

    for p in codefiles:
        fname = op.basename(p)
        fcopy(p,op.join(binpath,fname),link=args.link,force=args.force,test=args.test)

    ############### basic setup directory ###############
    setdir = op.join(fpath,'setup')
    print '\n@ '+setdir+'\n'
    files_mac = {\
                'zshrc_file':'~/.zshrc', \
                'matplotlibrc':'~/.matplotlib/', \
                }

    files_linux = {\
                  'zshrc_file':'~/.zshrc', \
                  'terminator_config':'~/.config/terminator/config', \
                  'matplotlibrc':'~/.config/matplotlib', \
                }
    if os.uname()[0] == 'Darwin':
        files = files_mac
    elif os.uname()[0] == 'Linux':
        files = files_linux
    else:
        files = {}

    for fy in files:
        spath = op.join(setdir,fy)
        if op.exists(spath):
            fcopy(spath,files[fy],force=args.force,test=args.test)

    zshrc_mine = op.expanduser('~/.zshrc.mine')
    if not op.exists(zshrc_mine):
        with open(zshrc_mine,'a') as f:
            print >> f,'## PC dependent zshrc'
            print >> f,'#'
            print >> f,'\n'


    ############### vim setup directory ###############
    vimdir = op.join(fpath,'vim')
    print '\n@ '+vimdir+'\n'

    vim_config_dir = op.expanduser('~/.config/nvim')
    rcdir = op.join(vim_config_dir, 'rcdir')
    ftdir = op.join(vim_config_dir, 'ftplugin')
    mkdir(rcdir)
    mkdir(ftdir)
    mkdir(op.join(vim_config_dir, "swp"))

    if args.download:
        mkdir('tmp')
        os.chdir(op.join(fpath,'tmp'))

        #print '\nclone neobundle'
        #mkdir('~/.vim/bundle/')
        #subprocess.call('git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim',shell=True)

        print '\nclone dein'
        mkdir('~/.config/nvim/dein')
        subprocess.call('curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh && chmod u+x installer.sh && ./installer.sh ~/.config/nvim/dein',shell=True)

        print '\nclone inkpot'
        subprocess.call('git clone https://github.com/ciaranm/inkpot',shell=True)
        subprocess.call('cp -ri ./inkpot/colors ~/.vim',shell=True)

        #print '\nclone seiya'
        #subprocess.call('git clone https://github.com/miyakogi/seiya.vim',shell=True)
        #subprocess.call('cp -ri ./seiya.vim/plugin ~/.vim',shell=True)

        #print '\nclone quickrun'
        #subprocess.call('git clone https://github.com/thinca/vim-quickrun.git',shell=True)
        #subprocess.call('cp -ri ./vim-quickrun/plugin/quickrun.vim ~/.vim/plugin/',shell=True)

        #print '\nclone taglist'
        #subprocess.call('git clone https://github.com/vim-scripts/taglist.vim',shell=True)
        #subprocess.call('cp -ri ./taglist.vim/plugin/taglist.vim ~/.vim/plugin/',shell=True)

        print '\nclone current-func-info'
        subprocess.call('git clone https://github.com/tyru/current-func-info.vim.git',shell=True)
        subprocess.call('cp -ri ./current-func-info.vim/autoload ~/.vim',shell=True)
        subprocess.call('cp -ri ./current-func-info.vim/doc ~/.vim',shell=True)
        subprocess.call('cp -ri ./current-func-info.vim/ftplugin ~/.vim',shell=True)
        subprocess.call('cp -ri ./current-func-info.vim/plugin ~/.vim',shell=True)

        print '\nremove download tmp files'
        subprocess.call('rm -rf %s' % op.join(fpath,'tmp','*'),shell=True)
        os.chdir(fpath)

    for fy in glob.glob(op.join(vimdir, 'rcdir', "*")):
        fcopy(fy, op.join(rcdir, op.basename(fy)), link=bool(args.link), force=args.force, test=args.test)

    for fy in glob.glob(op.join(vimdir, 'ftplugin', "*")):
        fcopy(fy, op.join(ftdir, op.basename(fy)), link=bool(args.link), force=args.force, test=args.test)

    vim_mine = op.expanduser('~/.config/nvim/rcdir/vimrc.mine')
    if not op.exists(vim_mine):
        with open(vim_mine,'a') as f:
            print >> f,'"" PC dependent vimrc'
            print >> f,'"'
            print >> f,'\n'

    vim_init = op.expanduser('~/.config/nvim/rcdir/init.vim.mine')
    if not op.exists(vim_init):
        with open(vim_init,'a') as f:
            print >> f,'"" init setting file for vim'
            print >> f,'"'
            print >> f,'\n'

    src = op.join(vimdir, "vimrc")
    dst = op.expanduser('~/.vimrc')
    if not op.exists(dst):
        print("link " + src + " -> " + dst)
        os.symlink(src, dst)

    src = vim_config_dir
    dst = op.expanduser("~/.vim")
    if not op.exists(dst):
        print("link " + src + " -> " + dst)
        os.symlink(src, dst)

