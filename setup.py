
from __future__ import print_function
import os
import os.path as op
import sys
sys.path.append(op.join(op.dirname(__file__), 'opt/lib'))
import argparse
import shutil
import subprocess
import glob
import filecmp
import difflib
import datetime
import json
import tempfile
import platform
if sys.version_info.major < 3:
    import urllib as urlreq
else:
    import urllib.request as urlreq
#if float(sys.version[:3]) < 2.7:
    #import commands

from local_lib import mkdir, chk_cmd
try:
    from local_lib_color import FG256, END
    is_color = True
except ImportError:
    is_color = False

uname = platform.system()

### copy func {{{
# copy file1 -> file2
def fcopy(file1,file2,link=False,force=False,**kwargs):
    def fcopy_main(cmd,comment,test):
        if is_color:
            fg = FG256(11)
            end = END
        else:
            fg = ''
            end = ''
        if not test:
            eval(cmd)
            print(fg+comment+end)
        else:
            print('{}cmd check:: {}{}'.format(fg, cmd, end))

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

    file1 = op.expanduser(file1)
    file2 = op.expanduser(file2)
    if not op.exists(file1):
        print("No such file: {}".format(file1))
        return
    name1 = op.basename(file1)
    name2 = op.basename(file2)
    cpdir = op.dirname(file2)

    if 'test' in kwargs:
        test = kwargs['test']
    else:
        test = False

    if 'condition' in kwargs:
        condition = kwargs['condition']
    else:
        condition = True

    if not test:
        mkdir(cpdir)
    else:
        if not os.path.exists(cpdir):
            print('process check:: mkdir {}'.format(cpdir))

    if op.lexists(file2):
        exist = True
        if op.islink(file2):
            islink = True
            linkpath = op.join(cpdir, os.readlink(file2))
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
                print(shift+'[ {} ] is already linked.'.format(home_cut(file2)))
            else:
                print(shift+'[ {} ] is already exist, cannot link!'.format(home_cut(file2)))
        else:
            fcopy_main(cmd,comment,test)

    else:       #copy
        cmd = 'shutil.copy("{}", "{}")'.format(file1, file2)
        comment = 'copy {} --> {}'.format(name1, home_cut(file2))

        if not condition:
            print(shift+"condition doesn't match" )
        elif force:
            if islink:
                print(shift+'[ {} ] is a link file, cannot copy!'.format(home_cut(file2)))
            else:
                fcopy_main(cmd, comment, test)
        elif exist:
            if filecmp.cmp(file1, file2) and islink:
                print(shift+'[ {} ] is linked.'.format(home_cut(file2)))
            elif filecmp.cmp(file1, file2):
                print(shift+'[ {} ] is already copied.'.format(home_cut(file2)))
            elif islink:
                print(shift+'[ {} ] is a link file, cannot copy!'.format(home_cut(file2)))
            else:
                is_diff = False
                while True:
                    if is_diff:
                        input_str = shift+'are you realy overwrite? [y(yes), n(no)] '
                    else:
                        input_str = shift+'[ {} ] is already exist, are you realy overwrite? [y(yes), n(no), d(diff)] '.format(home_cut(file2))
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

def home_cut(path):
    home = op.expandvars('$HOME')
    home2 = op.realpath(home)   # if home is symbolic link.
    if home2 in path:
        path = path.replace(home2, '~')
    elif home in path:
        path = path.replace(home, '~')
    return path

def get_files(fpath, args_type, prefix):
    if fpath is None:
        return None

    fpath = op.expanduser(fpath)
    fpath = op.expandvars(fpath)
    if not op.exists(fpath):
        print("setup_file {} doesn't find. use default settings.".format(fpath))
        return None

    with open(fpath, 'r') as f:
        set_dict = json.load(f)
    if args_type in set_dict:
        res_files = {}
        for src in set_dict[args_type]:
            dest = set_dict[args_type][src]
            if '$PREFIX' in dest:
                dest = dest.replace('$PREFIX', prefix)
            res_files[src] = dest
        return res_files
    else:
        print("{} is not in {}. use default settings.".format(args_type, fpath))
        return None

def show_target_files(file_dict):
    if is_color:
        fg = FG256(2)
        end = END
    else:
        fg = ''
        end = ''

    print(fg+'target files'+end)
    for key in sorted(file_dict.keys()):
        print('{} => {}'.format(op.relpath(key), home_cut(file_dict[key])))
    print(fg+'=~=~=~=~=~=~=~=~=~='+end)

def main_opt(args):
    binpath = op.join(args.prefix,'bin')
    libpath = op.join(args.prefix,'lib')
    optdir = op.join(args.fpath,'opt')
    bindir = op.join(optdir,'bin')
    libdir = op.join(optdir, 'lib')
    if is_color:
        fg = FG256(10)
        end = END
    else:
        fg = ''
        end = ''
    print('\n'+fg+'@ '+optdir+end+'\n')

    files = get_files(args.setup_file, 'opt', args.prefix)
    if files is None:
        files = {}

        if args.type != 'min':
            for bfy in glob.glob(op.join(bindir,'*')):
                if os.access(bfy,os.X_OK):
                    fname = op.basename(bfy)
                    if (fname == 'pdf2jpg'):
                        if (uname == 'Darwin'):
                            files[bfy] = op.join(binpath, fname)
                    else:
                        files[bfy] = op.join(binpath, fname)

            for lfy in glob.glob(op.join(libdir,'*')):
                fname = op.basename(lfy)
                if fname == '__pycache__':
                    continue
                if not fname.endswith('pyc'):
                    files[lfy] = op.join(libpath, fname)

    show_target_files(files)
    for fy in sorted(files.keys()):
        optpath = op.join(optdir, fy)
        fcopy(optpath, files[fy], link=args.link, force=args.force, test=args.test)

def main_conf(args):
    binpath = op.join(args.prefix,'bin')
    libpath = op.join(args.prefix,'lib')
    setdir = op.join(args.fpath,'config')
    if is_color:
        fg = FG256(10)
        end = END
    else:
        fg = ''
        end = ''
    print('\n'+fg+'@ '+setdir+end+'\n')

    files_mac = {\
                'zshrc':'~/.zshrc', \
                'zlogin':'~/.zlogin', \
                'zsh/alias.zsh': '~/.zsh/alias.zsh', \
                'zsh/complete.zsh': '~/.zsh/complete.zsh', \
                'zsh/functions.zsh': '~/.zsh/functions.zsh', \
                'zsh/prompt.zsh': '~/.zsh/prompt.zsh', \
                'posixShellRC':'~/.posixShellRC',\
                'bashrc':'~/.bashrc',\
                'matplotlibrc':'~/.matplotlib/matplotlibrc', \
                'gitignore_global':'~/.gitignore_global', \
                'screenrc':'~/.screenrc', \
                'marp/marp_MeFtheme.css':'~/.marp/marp_MeFtheme.css', \
                }

    files_linux = {\
                  'zshrc':'~/.zshrc', \
                  'zlogin':'~/.zlogin', \
                  'zsh/alias.zsh': '~/.zsh/alias.zsh', \
                  'zsh/complete.zsh': '~/.zsh/complete.zsh', \
                  'zsh/functions.zsh': '~/.zsh/functions.zsh', \
                  'zsh/prompt.zsh': '~/.zsh/prompt.zsh', \
                  'posixShellRC':'~/.posixShellRC',\
                  'bashrc':'~/.bashrc',\
                  'terminator_config':op.join(args.conf_home,'terminator/config'), \
                  'terminology_base.cfg':op.join(args.conf_home, 'terminology/config/standard/base.cfg'), \
                  'matplotlibrc':op.join(args.conf_home, 'matplotlib/matplotlibrc'), \
                  'gitignore_global':'~/.gitignore_global', \
                  'screenrc':'~/.screenrc', \
                }

    files_win = {}

    files_min = {\
                  'posixShellRC':'~/.posixShellRC',\
                  'bashrc':'~/.bashrc',\
                  'gitignore_global':'~/.gitignore_global', \
                }

    files = get_files(args.setup_file, 'config', args.prefix)
    if files is None:
        if args.type == 'min':
            files = files_min
        elif uname == 'Darwin':
            files = files_mac
        elif uname == 'Linux':
            files = files_linux
        elif uname == 'Windows':
            files = files_win
        else:
            files = {}

    if args.download:
        print('download git-prompt for bash')
        bashdir = op.expandvars('$HOME/.bash')
        mkdir(bashdir)
        urlreq.urlretrieve('https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh', op.join(bashdir, 'git-prompt.sh'))

    show_target_files(files)
    for fy in sorted(files.keys()):
        spath = op.join(setdir,fy)
        fy_dir = op.dirname(op.expanduser(files[fy]))
        if op.exists(fy_dir):
            fcopy(spath,files[fy], link=bool(args.link), force=args.force,test=args.test)
        else:
            print('{} does not exist, do not copy {}.'.format(fy_dir, fy))

    pyopt = '--prefix ' + args.prefix
    pyopt += ' --type ' + args.type
    if args.setup_file is not None:
        pyopt += ' --setup_file '+args.setup_file
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
            " && python3 setup.py {}".format(pyopt) +\
            " ; cd -'"
    mine_exist = True

    if 'zshrc' in files:
        zshrc_mine = op.expandvars('$HOME/.zsh/zshrc.mine')
        if not op.exists(zshrc_mine):
            mkdir('~/.zsh')
            with open(zshrc_mine,'a') as f:
                f.write('## PC dependent zshrc\n')
                f.write('#\n')
                f.write('\n')
                f.write('export PATH=\\\n' + binpath + ':\\\n$PATH')
                f.write('\n')
                f.write('export PYTHONPATH=\\\n' + libpath + ':\\\n$PYTHONPATH')
                f.write('\n\n')
                f.write(up_stup)
                f.write('\n\n')
            print('made zshrc.mine')
            mine_exist = False

    if 'bashrc' in files:
        bashrc_mine = op.expanduser('~/.bash/bashrc.mine')
        if not op.exists(bashrc_mine):
            mkdir('~/.bash')
            with open(bashrc_mine,'a') as f:
                f.write('## PC dependent bashrc\n')
                f.write('#\n')
                f.write('\n')
                f.write('export PATH=\\\n' + binpath + ':\\\n$PATH')
                f.write('\n')
                f.write('export PYTHONPATH=\\\n' + libpath + ':\\\n$PYTHONPATH')
                f.write('\n\n')
                f.write(up_stup)
                f.write('\n\n')
            print('made bashrc.mine')
            mine_exist = False

    if mine_exist:
        print('  update alias is\n{}'.format(up_stup))

def main_vim(args):
    vimdir = op.join(args.fpath,'vim')
    if is_color:
        fg = FG256(10)
        end = END
    else:
        fg = ''
        end = ''
    print('\n'+fg+'@ '+vimdir+end+'\n')

    if uname == 'Windows':
        vim_config_path = op.expanduser('~/vimfiles')
    else:
        vim_config_path = op.join(args.conf_home, 'nvim')
    rcpath = op.join(vim_config_path, 'rcdir')
    ftpath = op.join(vim_config_path, 'ftplugin')
    tmpath = op.join(vim_config_path, 'toml')
    alpath = op.join(vim_config_path, 'autoload')
    libpath = op.join(vim_config_path, 'autoload/meflib')
    mkdir(op.join(vim_config_path, "swp"))

    files = get_files(args.setup_file, 'vim', args.prefix)
    if uname == 'Windows':
        vimrc = op.expanduser('~/_vimrc')
    else:
        vimrc = op.join(vim_config_path, 'init.vim')
    if files is None:
        if args.type == 'min':
            files = {'rcdir/vimrc_basic.vim':vimrc}
        else:
            files = {'vimrc':vimrc}
            for fy in glob.glob(op.join(vimdir, 'rcdir', "*")):
                fname = op.basename(fy)
                files[fy] = op.join(rcpath, fname)
            for fy in glob.glob(op.join(vimdir, 'ftplugin', "*")):
                fname = op.basename(fy)
                files[fy] = op.join(ftpath, fname)
            for fy in glob.glob(op.join(vimdir, 'toml', "*")):
                fname = op.basename(fy)
                files[fy] = op.join(tmpath, fname)
            for fy in glob.glob(op.join(vimdir, 'autoload', "*")):
                if op.isfile(fy):
                    fname = op.basename(fy)
                    files[fy] = op.join(alpath, fname)
            for fy in glob.glob(op.join(vimdir, 'autoload/meflib', "*")):
                fname = op.basename(fy)
                files[fy] = op.join(libpath, fname)

    if (args.type != 'min') and args.download and chk_cmd('sh', True):
        print('\nclone dein')
        dein_path = op.join(vim_config_path, 'dein')
        mkdir(dein_path)

        if hasattr(tempfile, 'TemporaryDirectory'):
            with tempfile.TemporaryDirectory() as tmpdir:
                os.chdir(tmpdir)
                urlreq.urlretrieve('https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh', 'installer.sh')
                subprocess.call('sh installer.sh {}'.format(dein_path), shell=True)
                os.chdir(args.fpath)
        else:
            tmpdir = tempfile.mkdtemp()
            os.chdir(tmpdir)
            urlreq.urlretrieve('https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh', 'installer.sh')
            subprocess.call('sh installer.sh {}'.format(dein_path), shell=True)
            os.chdir(args.fpath)
            shutil.rmtree(tmpdir)

        print('\nremoved download tmp files')

    show_target_files(files)
    for fy in sorted(files.keys()):
        vimpath = op.join(vimdir, fy)
        fcopy(vimpath, files[fy], link=args.link, force=args.force, test=args.test)

    if not uname == 'Windows':
        src = vimrc
        dst = op.expanduser('~/.vimrc')
        if not op.exists(dst):
            if not args.test:
                print("link " + src + " -> " + dst)
                os.symlink(src, dst)

        src = vim_config_path
        dst = op.expanduser("~/.vim")
        if not op.exists(dst):
            if not args.test:
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
    parser.add_argument('-s', '--setup_file', help='specify the copy files by json format setting file. please see "opt/test/setup_file_template.json" as an example.')
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

    if args.type in 'all opt min'.split():
        main_opt(args)
    if args.type in 'all config min'.split():
        main_conf(args)
    if args.type in 'all vim min'.split():
        main_vim(args)

if __name__ == "__main__":
    main()

