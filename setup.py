
from __future__ import print_function
import os
import os.path as op
import sys
import argparse
import shutil
import subprocess
import glob
import filecmp
import difflib
import datetime
#if float(sys.version[:3]) < 2.7:
    #import commands


def mkdir(path):
    path = op.expanduser(path)
    if not op.exists(path):
        print('mkdir '+path)
        os.makedirs(path, mode=0o755)
        #os.chmod(path,0755)

### copy func {{{
# copy file1 -> file2
def fcopy(file1,file2,link=False,force=False,**kwargs):
    def fcopy_main(cmd,comment,test):
        if not test:
            eval(cmd)
            print(comment)
        else:
            print('cmd check:: '+cmd)


    def fcopy_diff(file1, file2):
        # https://it-ojisan.tokyo/python-difflib/#keni_toc_2
        fname1 = op.basename(file1)
        fname2 = op.basename(file2)
        dt1 = datetime.datetime.fromtimestamp(os.stat(file1).st_mtime)
        dt2 = datetime.datetime.fromtimestamp(os.stat(file2).st_mtime)

        with open(file1, 'r') as f:
            str1 = f.readlines()
        with open(file2, 'r') as f:
            str2 = f.readlines()

        for line in difflib.unified_diff(str1, str2, n=1, \
                fromfile=fname1, tofile=fname2, \
                fromfiledate=dt1.strftime('%m %d (%Y) %H:%M:%S'), tofiledate=dt2.strftime('%m %d (%Y) %H:%M:%S')):
            print(line, end='')

    file1 = op.expanduser(file1)
    file2 = op.expanduser(file2)
    name1 = op.basename(file1)
    name2 = op.basename(file2)
    mkdir(op.dirname(file2))

    if 'test' in kwargs:
        test = kwargs['test']
    else:
        test = False

    if 'condition' in kwargs:
        condition = kwargs['condition']
    else:
        condition = True

    if op.exists(file2):
        exist = True
        if op.islink(file2):
            islink = True
        else:
            islink = False
    else:
        exist = False
        islink = False


    if link:    #link
        cmd = 'os.symlink("%s", "%s")' % (file1, file2)
        comment = 'linked '+name1

        if not condition:
            print( "condition doesn't match" )
        elif exist:
            if islink and filecmp.cmp(file1, file2):
                print('  [ %s ] is already linked.' % name2)
            else:
                print('  [  %s  ] is already exist, cannot link!' % name2)
        else:
            fcopy_main(cmd,comment,test)

    else:       #copy
        cmd = 'shutil.copy("%s", "%s")' % (file1, file2)
        comment = 'copy %s --> %s' % (name1,file2)

        if not condition:
            print( "condition doesn't match" )
        elif force:
            if islink:
                print('  [ %s ] is a link file, cannot copy!' % name2)
            else:
                fcopy_main(cmd, comment, test)
        elif exist:
            if filecmp.cmp(file1, file2) and islink:
                print('  [ %s ] is linked.' % name2)
            elif filecmp.cmp(file1, file2):
                print('  [ %s ] is already copied.' % name2)
            elif islink:
                print('  [ %s ] is a link file, cannot copy!' % name2)
            else:
                input_str = '  [  %s  ] is already exist, are you realy overwrite? [y(yes), n(no), d(diff)] ' % name2
                if sys.version_info[0] == 2:
                    yn = raw_input(input_str)
                else:
                    yn = input(input_str)
                if (yn == 'y') or (yn == 'yes'):
                    fcopy_main(cmd, comment, test)
                elif (yn == 'd') or (yn == 'diff'):
                    print('Do not copy '+name2)
                    print('')
                    fcopy_diff(file1, file2)
                    print('')
                else:
                    print('Do not copy '+name2)
        else:
            fcopy_main(cmd, comment, test)
#}}}

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
        print("install path %s does not exit" % args.prefix)
        exit()

    fpath = op.dirname(op.abspath(__file__))
    binpath = op.join(args.prefix,'bin')
    libpath = op.join(args.prefix,'lib')
    os.chdir(fpath)

    if 'XDG_CONFIG_HOME' in os.environ:
        conf_home = os.environ['XDG_CONFIG_HOME']
    else:
        conf_home = op.expanduser('~/.config')

    ############### script directory ############### {{{
    optdir = op.join(fpath,'opt')
    print('\n@ '+optdir+'\n')

    bindir = op.join(optdir,'bin')
    optfiles = []
    for bfy in glob.glob(op.join(bindir,'*')):
        if os.access(bfy,os.X_OK):
            if (op.basename(bfy) == 'pdf2jpg'):
                if (os.uname()[0] == 'Darwin'):
                    optfiles.append(bfy)
            else:
                optfiles.append(bfy)
    for p in optfiles:
        fname = op.basename(p)
        fcopy(p,op.join(binpath,fname),link=args.link,force=args.force,test=args.test)

    libdir = op.join(optdir, 'lib')
    for lfy in glob.glob(op.join(libdir,'*')):
        fname = op.basename(lfy)
        fcopy(lfy,op.join(libpath,fname),link=args.link,force=args.force,test=args.test)

    # }}}

    ############### basic config directory ############### {{{
    setdir = op.join(fpath,'config')
    print('\n@ '+setdir+'\n')
    files_mac = {\
                'zshrc_file':'~/.zshrc', \
                'posixShellRC':'~/.posixShellRC',\
                'bashrc_file':'~/.bashrc',\
                'matplotlibrc':'~/.matplotlib/matplotlibrc', \
                }

    files_linux = {\
                  'zshrc_file':'~/.zshrc', \
                  'posixShellRC':'~/.posixShellRC',\
                  'bashrc_file':'~/.bashrc',\
                  'terminator_config':op.join(conf_home,'terminator/config'), \
                  'matplotlibrc':op.join(conf_home, 'matplotlib/matplotlibrc'), \
                }
    if os.uname()[0] == 'Darwin':
        files = files_mac
    elif os.uname()[0] == 'Linux':
        files = files_linux
    else:
        files = {}

    for fy in files:
        spath = op.join(setdir,fy)
        fy_dir = op.dirname(op.expanduser(files[fy]))
        if op.exists(spath) and op.exists(fy_dir):
            fcopy(spath,files[fy], link=bool(args.link), force=args.force,test=args.test)

    zshdir = op.expanduser('~/.zsh')
    zshrc_mine = op.join(zshdir, 'zshrc.mine')
    mkdir(zshdir)
    if not op.exists(zshrc_mine):
        pyopt = ' --prefix ' + args.prefix
        if args.link:
            pyopt += ' --link '
        if args.force:
            pyopt += ' --force '
        with open(zshrc_mine,'a') as f:
            f.write('## PC dependent zshrc\n')
            f.write('#\n')
            f.write('\n')
            f.write('export PATH=\\\n' + binpath + ':\\\n$PATH')
            f.write('\n\n')
            f.write("alias update_setup='cd " + fpath +\
                    " && git pull " +\
                    " && echo \"update? (y/[n])\" " +\
                    " && read YN " +\
                    " && [[ $YN = \"y\" ]] " +\
                    " && python setup.py " + pyopt +\
                    " ; cd -'")
            f.write('\n\n')
        print('made zshrc.mine')

    for fy in glob.glob(op.join(setdir, 'zsh', '*')):
        fcopy(fy, op.join(zshdir, op.basename(fy)), link=bool(args.link), force=args.force, test=args.test)

    # }}}

    ############### vim setup directory ############### {{{
    vimdir = op.join(fpath,'vim')
    print('\n@ '+vimdir+'\n')

    vim_config_dir = op.join(conf_home, 'nvim')
    rcdir = op.join(vim_config_dir, 'rcdir')
    ftdir = op.join(vim_config_dir, 'ftplugin')
    tmdir = op.join(vim_config_dir, 'toml')
    mkdir(op.join(vim_config_dir, "swp"))

    if args.download:
        mkdir('tmp')
        os.chdir(op.join(fpath,'tmp'))

        #print '\nclone neobundle'
        #mkdir('~/.vim/bundle/')
        #subprocess.call('git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim',shell=True)

        print('\nclone dein')
        mkdir(op.join(conf_home, 'nvim/dein'))
        subprocess.call('curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh && chmod u+x installer.sh && ./installer.sh %s/nvim/dein' % conf_home, shell=True)

        #print '\nclone inkpot'
        #subprocess.call('git clone https://github.com/ciaranm/inkpot',shell=True)
        #subprocess.call('cp -ri ./inkpot/colors ~/.config/nvim/',shell=True)

        #print '\nclone seiya'
        #subprocess.call('git clone https://github.com/miyakogi/seiya.vim',shell=True)
        #subprocess.call('cp -ri ./seiya.vim/plugin ~/.vim',shell=True)

        #print '\nclone quickrun'
        #subprocess.call('git clone https://github.com/thinca/vim-quickrun.git',shell=True)
        #subprocess.call('cp -ri ./vim-quickrun/plugin/quickrun.vim ~/.vim/plugin/',shell=True)

        #print '\nclone taglist'
        #subprocess.call('git clone https://github.com/vim-scripts/taglist.vim',shell=True)
        #subprocess.call('cp -ri ./taglist.vim/plugin/taglist.vim ~/.vim/plugin/',shell=True)

        #print '\nclone current-func-info'
        #subprocess.call('git clone https://github.com/tyru/current-func-info.vim.git',shell=True)
        #subprocess.call('cp -ri ./current-func-info.vim/autoload ~/.config/nvim/',shell=True)
        #subprocess.call('cp -ri ./current-func-info.vim/doc ~/.config/nvim/',shell=True)
        #subprocess.call('cp -ri ./current-func-info.vim/ftplugin ~/.config/nvim/',shell=True)
        #subprocess.call('cp -ri ./current-func-info.vim/plugin ~/.config/nvim/',shell=True)

        print('\nremove download tmp files')
        os.chdir(fpath)
        shutil.rmtree(op.join(fpath, 'tmp'))

    fcopy(op.join(vimdir, "vimrc"), op.join(vim_config_dir, "init.vim"), link=bool(args.link), force=args.force, test=args.test)
    for fy in glob.glob(op.join(vimdir, 'rcdir', "*")):
        fcopy(fy, op.join(rcdir, op.basename(fy)), link=bool(args.link), force=args.force, test=args.test)

    for fy in glob.glob(op.join(vimdir, 'ftplugin', "*")):
        fcopy(fy, op.join(ftdir, op.basename(fy)), link=bool(args.link), force=args.force, test=args.test)

    for fy in glob.glob(op.join(vimdir, 'toml', "*")):
        fcopy(fy, op.join(tmdir, op.basename(fy)), link=bool(args.link), force=args.force, test=args.test)

    vim_mine = op.expanduser('~/.config/nvim/rcdir/vimrc.mine')
    if not op.exists(vim_mine):
        with open(vim_mine,'a') as f:
            f.write('"" PC dependent vimrc\n')
            f.write('"\n')
            f.write('\n')

    vim_init = op.expanduser('~/.config/nvim/rcdir/init.vim.mine')
    if not op.exists(vim_init):
        with open(vim_init,'a') as f:
            f.write('"" init setting file for vim\n')
            f.write('"\n')
            f.write('\n')

    src = op.join(vim_config_dir, "init.vim")
    dst = op.expanduser('~/.vimrc')
    if not op.exists(dst):
        print("link " + src + " -> " + dst)
        os.symlink(src, dst)

    src = vim_config_dir
    dst = op.expanduser("~/.vim")
    if not op.exists(dst):
        print("link " + src + " -> " + dst)
        os.symlink(src, dst)

    # }}}

