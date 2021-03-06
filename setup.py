
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
if sys.version_info.major < 3:
    import urllib as urlreq
else:
    import urllib.request as urlreq
#if float(sys.version[:3]) < 2.7:
    #import commands

try:
    from color_test import FG256, END
    is_color = True
except ImportError:
    is_color = False

def mkdir(path):
    path = op.expanduser(path)
    if not op.exists(path):
        print('mkdir '+path)
        os.makedirs(path, mode=0o755)
        #os.chmod(path,0755)

def chk_cmd(cmd):   # check the command exists.
    if not 'PATH' in os.environ:
        print("PATH isn't found in environment values.")
        return False
    for path in os.environ['PATH'].split(os.pathsep):
        cmd_path = op.join(path, cmd)
        if op.isfile(cmd_path) and os.access(cmd_path, os.X_OK):
            print(cmd_path)
            return True

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
        dt1 = datetime.datetime.fromtimestamp(os.stat(file1).st_mtime)
        dt2 = datetime.datetime.fromtimestamp(os.stat(file2).st_mtime)

        with open(file1, 'r') as f:
            str1 = f.readlines()
        with open(file2, 'r') as f:
            str2 = f.readlines()

        shift = '   |'
        for line in difflib.unified_diff(str1, str2, n=1, \
                fromfile=home_cut(file1), tofile=home_cut(file2), \
                fromfiledate=dt1.strftime('%m %d (%Y) %H:%M:%S'), tofiledate=dt2.strftime('%m %d (%Y) %H:%M:%S')):
            line = line.replace('\n', '')
            if is_color and (line[0] == '+'):
                col = FG256(12)
                end = END
            elif is_color and (line[0] == '-'):
                col = FG256(1)
                end = END
            else:
                col = ''
                end = ''
            print(shift+col+line+end)

    def get_input(input_str):
        if sys.version_info[0] == 2:
            yn = raw_input(input_str)
        else:
            yn = input(input_str)
        return yn

    def home_cut(path):
        home = op.expandvars('$HOME')
        home2 = op.realpath(home)   # if home is symbolic link.
        if home2 in path:
            path = path.replace(home2, '~')
        elif home in path:
            path = path.replace(home, '~')
        return path

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

    if op.lexists(file2):
        exist = True
        if op.islink(file2):
            islink = True
            linkpath = op.join(op.dirname(file2), os.readlink(file2))
            if not op.exists(linkpath):
                # broken link
                os.unlink(file2)
                print('{} -> {} is a broken link. unlink this.'.format(home_cut(file2), home_cut(linkpath)))
                exist = False
                islink = False
        else:
            islink = False
    else:
        exist = False
        islink = False


    shift = '  '
    if link:    #link
        cmd = 'os.symlink("{}", "{}")'.format(file1, file2)
        comment = 'linked {} --> {}'.format(name1, home_cut(file2))

        if not condition:
            print(shift+"condition doesn't match" )
        elif exist:
            if islink and filecmp.cmp(file1, file2):
                print(shift+'[ {} ] is already linked.'.format(name2))
            else:
                print(shift+'[ {} ] is already exist, cannot link!'.format(name2))
        else:
            fcopy_main(cmd,comment,test)

    else:       #copy
        cmd = 'shutil.copy("{}", "{}")'.format(file1, file2)
        comment = 'copy {} --> {}'.format(name1, home_cut(file2))

        if not condition:
            print(shift+"condition doesn't match" )
        elif force:
            if islink:
                print(shift+'[ {} ] is a link file, cannot copy!'.format(name2))
            else:
                fcopy_main(cmd, comment, test)
        elif exist:
            if filecmp.cmp(file1, file2) and islink:
                print(shift+'[ {} ] is linked.'.format(name2))
            elif filecmp.cmp(file1, file2):
                print(shift+'[ {} ] is already copied.'.format(name2))
            elif islink:
                print(shift+'[ {} ] is a link file, cannot copy!'.format(name2))
            else:
                is_diff = False
                while True:
                    if is_diff:
                        input_str = shift+'are you realy overwrite? [y(yes), n(no)] '
                    else:
                        input_str = shift+'[ {} ] is already exist, are you realy overwrite? [y(yes), n(no), d(diff)] '.format(name2)
                    yn = get_input(input_str)
                    if (yn == 'y') or (yn == 'yes'):
                        fcopy_main(cmd, comment, test)
                        break
                    elif ((yn == 'd') or (yn == 'diff')) and not is_diff:
                        print('')
                        fcopy_diff(file2, file1)
                        print('')
                        is_diff = True
                    elif (yn == 'n') or (yn == 'no'):
                        print('Do not copy '+name2)
                        break
        else:
            fcopy_main(cmd, comment, test)
#}}}

def main_opt(args):
    binpath = op.join(args.prefix,'bin')
    libpath = op.join(args.prefix,'lib')
    optdir = op.join(args.fpath,'opt')
    print('\n@ '+optdir+'\n')

    bindir = op.join(optdir,'bin')
    binfiles = []
    for bfy in glob.glob(op.join(bindir,'*')):
        if os.access(bfy,os.X_OK):
            if (op.basename(bfy) == 'pdf2jpg'):
                if (os.uname()[0] == 'Darwin'):
                    binfiles.append(bfy)
            else:
                binfiles.append(bfy)

    for b in binfiles:
        fname = op.basename(b)
        fcopy(b,op.join(binpath,fname),link=args.link,force=args.force,test=args.test)

    libdir = op.join(optdir, 'lib')
    for lfy in glob.glob(op.join(libdir,'*')):
        fname = op.basename(lfy)
        fcopy(lfy,op.join(libpath,fname),link=args.link,force=args.force,test=args.test)

def main_conf(args):
    binpath = op.join(args.prefix,'bin')
    setdir = op.join(args.fpath,'config')
    print('\n@ '+setdir+'\n')

    files_mac = {\
                'zshrc':'~/.zshrc', \
                'zlogin':'~/.zlogin', \
                'posixShellRC':'~/.posixShellRC',\
                'bashrc':'~/.bashrc',\
                'matplotlibrc':'~/.matplotlib/matplotlibrc', \
                'gitignore_global':'~/.gitignore_global', \
                }

    files_linux = {\
                  'zshrc':'~/.zshrc', \
                  'zlogin':'~/.zlogin', \
                  'posixShellRC':'~/.posixShellRC',\
                  'bashrc':'~/.bashrc',\
                  'terminator_config':op.join(args.conf_home,'terminator/config'), \
                  'matplotlibrc':op.join(args.conf_home, 'matplotlib/matplotlibrc'), \
                  'gitignore_global':'~/.gitignore_global', \
                }

    files_min = {\
                  'posixShellRC':'~/.posixShellRC',\
                  'bashrc':'~/.bashrc',\
                  'gitignore_global':'~/.gitignore_global', \
                }

    if os.uname()[0] == 'Darwin':
        if args.type == 'min':
            files = files_min
        else:
            files = files_mac
    elif os.uname()[0] == 'Linux':
        if args.type == 'min':
            files = files_min
        else:
            files = files_linux
    else:
        files = {}

    zshdir = op.expanduser('~/.zsh')
    mkdir(zshdir)
    bashdir = op.expanduser('~/.bash')
    mkdir(bashdir)

    if args.download:
        print('download git-prompt for bash')
        urlreq.urlretrieve('https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh', op.expanduser('~/.bash/git-prompt.sh'))

    for fy in files:
        spath = op.join(setdir,fy)
        fy_dir = op.dirname(op.expanduser(files[fy]))
        if op.exists(spath) and op.exists(fy_dir):
            fcopy(spath,files[fy], link=bool(args.link), force=args.force,test=args.test)

    pyopt = '--prefix ' + args.prefix
    pyopt += ' --type ' + args.type
    if args.link:
        pyopt += ' --link'
    if args.force:
        pyopt += ' --force'
    up_stup = \
            "alias update_setup='cd {}".format(args.fpath) +\
            " && git pull" +\
            " && echo \"update? (y/[n])\"" +\
            " && read YN" +\
            " && [[ $YN = \"y\" ]]" +\
            " && python setup.py {}".format(pyopt) +\
            " ; cd -'"
    zshrc_mine = op.join(zshdir, 'zshrc.mine')
    bashrc_mine = op.join(bashdir, 'bashrc.mine')
    mine_exist = True
    if not args.type == 'min':
        if not op.exists(zshrc_mine):
            with open(zshrc_mine,'a') as f:
                f.write('## PC dependent zshrc\n')
                f.write('#\n')
                f.write('\n')
                f.write('export PATH=\\\n' + binpath + ':\\\n$PATH')
                f.write('\n\n')
                f.write(up_stup)
                f.write('\n\n')
            print('made zshrc.mine')
            mine_exist = False
    if not op.exists(bashrc_mine):
        with open(bashrc_mine,'a') as f:
            f.write('## PC dependent bashrc\n')
            f.write('#\n')
            f.write('\n')
            f.write('export PATH=\\\n' + binpath + ':\\\n$PATH')
            f.write('\n\n')
            f.write(up_stup)
            f.write('\n\n')
        print('made bashrc.mine')
        mine_exist = False
    if mine_exist:
        print('  update alias is\n{}'.format(up_stup))

    if not args.type == 'min':
        for fy in glob.glob(op.join(setdir, 'zsh', '*')):
            fcopy(fy, op.join(zshdir, op.basename(fy)), link=bool(args.link), force=args.force, test=args.test)

def main_vim(args):
    vimdir = op.join(args.fpath,'vim')
    print('\n@ '+vimdir+'\n')

    vim_config_dir = op.join(args.conf_home, 'nvim')
    rcdir = op.join(vim_config_dir, 'rcdir')
    ftdir = op.join(vim_config_dir, 'ftplugin')
    tmdir = op.join(vim_config_dir, 'toml')
    mkdir(op.join(vim_config_dir, "swp"))

    if args.type == 'min':
        fcopy(op.join(vimdir, "rcdir", 'vimrc_basic.vim'), op.join(vim_config_dir, "init.vim"), link=bool(args.link), force=args.force, test=args.test)
    else:
        if args.download and chk_cmd('sh'):
            mkdir('tmp')
            os.chdir(op.join(args.fpath,'tmp'))

            print('\nclone dein')
            mkdir(op.join(vim_config_dir, 'dein'))
            urlreq.urlretrieve('https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh', 'installer.sh')
            subprocess.call('sh installer.sh {}'.format(op.join(vim_config_dir, 'dein')), shell=True)

            print('\nremove download tmp files')
            os.chdir(args.fpath)
            shutil.rmtree(op.join(args.fpath, 'tmp'))

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

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix',help='install directory',default=op.expanduser('~/opt'))
    parser.add_argument('--download',help='download some files (from git)',action='store_true')
    parser.add_argument('--link',help="link files instead of copy",action='store_true')
    parser.add_argument('--test',help="don't copy, just show command",action='store_true')
    parser.add_argument('-f','--force',help="Do not prompt for confirmation before overwriting the destination path",action='store_true')
    parser.add_argument('-t', '--type', help="set the type of copy files. If min is specified, only copy *shrc, posixShellRC, and vimrc_basic.vim.", choices='all opt config vim min'.split(), default='all')
    args = parser.parse_args()

    if not op.exists(args.prefix):
        print("install path {} does not exit".format(args.prefix))
        exit()

    fpath = op.dirname(op.abspath(__file__))
    args.fpath = fpath
    os.chdir(fpath)

    if 'XDG_CONFIG_HOME' in os.environ:
        conf_home = os.environ['XDG_CONFIG_HOME']
    else:
        conf_home = op.expanduser('~/.config')
    args.conf_home = conf_home

    if args.type in 'all opt'.split():
        main_opt(args)
    if args.type in 'all config min'.split():
        main_conf(args)
    if args.type in 'all vim min'.split():
        main_vim(args)

if __name__ == "__main__":
    main()
