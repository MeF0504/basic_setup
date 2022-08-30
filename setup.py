
from __future__ import print_function

import os
import sys
import argparse
import shutil
import subprocess
import filecmp
import difflib
import datetime
import json
import tempfile
import platform
import urllib.request as urlreq
from pathlib import Path
sys.path.append(Path(__file__).parent/'opt'/'lib')
from local_lib import mkdir, chk_cmd
try:
    from local_lib_color import FG256, END
    is_color = True
except ImportError:
    is_color = False

uname = platform.system()
if uname == 'Windows':
    psep = ';'
else:
    psep = ':'

py_version = sys.version_info.major*1000 + \
             sys.version_info.minor
if py_version < 3006:
    print('Version >= 3.6 required')
    sys.exit()


# copy func {{{
def fcopy(src, dst, link=False, force=False, **kwargs):
    def fcopy_main(src, dst, link, comment, test):  # {{{
        if is_color:
            fg = FG256(11)
            end = END
        else:
            fg = ''
            end = ''
        if link:
            if test:
                print('{}cmd check:: link {} -> {}{}'.format(fg, src, dst, end))
                return
            else:
                os.symlink(src, dst)
        else:
            if test:
                print('{}cmd check:: copy {} -> {}{}'.format(fg, src, dst, end))
                return
            else:
                shutil.copy(src, dst)
        print('{}{}{}'.format(fg, comment, end))
        # }}}

    def fcopy_diff(file1, file2):  # {{{
        # https://it-ojisan.tokyo/python-difflib/#keni_toc_2
        dt1 = datetime.datetime.fromtimestamp(os.stat(file1).st_mtime)
        dt2 = datetime.datetime.fromtimestamp(os.stat(file2).st_mtime)

        with open(file1, 'r', encoding='utf-8') as f:
            str1 = f.readlines()
        with open(file2, 'r', encoding='utf-8') as f:
            str2 = f.readlines()

        shift = '   |'
        for line in difflib.unified_diff(str1, str2, n=1,
                fromfile=home_cut(file1), tofile=home_cut(file2),
                fromfiledate=dt1.strftime('%m %d (%Y) %H:%M:%S'),
                tofiledate=dt2.strftime('%m %d (%Y) %H:%M:%S')):
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
        # }}}

    src = Path(src).expanduser()
    dst = Path(dst).expanduser()
    if src.is_file():
        slist = [src]
        assert dst.is_file() or not dst.exists()
    elif src.is_dir():
        slist = src.glob("**/*")
        assert dst.is_dir() or not dst.exists()
    else:
        print("No such file or directory: {}".format(src))
        return

    if 'test' in kwargs:
        test = kwargs['test']
    else:
        test = False

    if 'condition' in kwargs:
        condition = kwargs['condition']
    else:
        condition = True

    for file1 in slist:
        if file1.is_dir():
            continue
        name1 = file1.name
        if src.is_dir():
            cpdir = dst/file1.parent.relative_to(src)
            file2 = cpdir/name1
        else:
            cpdir = dst.parent
            file2 = dst
        name2 = file2.name
        if not test:
            mkdir(cpdir)
        else:
            if not cpdir.exists():
                print('process check:: mkdir {}'.format(cpdir))

        if file2.exists():
            exist = True
            if file2.is_symlink():
                islink = True
                linkpath = cpdir.joinpath(file2.readlink())
                if not linkpath.exists():
                    # broken link
                    os.unlink(file2)
                    print('{} -> {} is a broken link. unlink this.'.format(
                        home_cut(file2), home_cut(linkpath)))
                    exist = False
                    islink = False
            else:
                islink = False
        else:
            exist = False
            islink = False

        shift = '  '
        if link:    # link
            comment = 'linked {} --> {}'.format(name1, home_cut(file2))

            if not condition:
                print(shift+"condition doesn't match")
            elif exist:
                if islink and filecmp.cmp(file1, file2):
                    print(shift+'[ {} ] is already linked.'
                          .format(home_cut(file2)))
                else:
                    print(shift+'[ {} ] is already exist, cannot link!'
                          .format(home_cut(file2)))
            else:
                fcopy_main(file1, file2, link, comment, test)

        else:       # copy
            comment = 'copy {} --> {}'.format(name1, home_cut(file2))

            if not condition:
                print(shift+"condition doesn't match")
            elif exist:
                if filecmp.cmp(file1, file2) and islink:
                    print(shift+'[ {} ] is linked.'.format(home_cut(file2)))
                elif filecmp.cmp(file1, file2):
                    print(shift+'[ {} ] is already copied.'
                          .format(home_cut(file2)))
                elif islink:
                    print(shift+'[ {} ] is a link file, cannot copy!'
                          .format(home_cut(file2)))
                elif force:
                    fcopy_main(file1, file2, link, comment, test)
                else:
                    is_diff = False
                    while True:
                        if is_diff:
                            input_str = shift +\
                                'are you really overwrite? [y(yes), n(no)] '
                        else:
                            input_str = shift +'[ {} ] is already exist, are you really overwrite? [y(yes), n(no), d(diff)] '.format(home_cut(file2))
                        yn = input(input_str)
                        if (yn == 'y') or (yn == 'yes'):
                            fcopy_main(file1, file2, link, comment, test)
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
                fcopy_main(file1, file2, link, comment, test)
# }}}


def home_cut(path):
    path = Path(path)
    home = Path.home()
    home2 = home.resolve()  # if home is symbolic link.
    if py_version < 3009:
        return str(path)
    elif path.is_relative_to(home2):
        return '~/{}'.format(path.relative_to(home2))
    elif path.is_relative_to(home):
        return '~/{}'.format(path.relative_to(home))
    else:
        return str(path)


def get_files(fpath, args_type, prefix):
    if fpath is None:
        return None

    fpath = Path(fpath).expanduser()
    if not fpath.exists():
        print("setup_file {} doesn't find. use default settings."
              .format(fpath))
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
        print("{} is not in {}. use default settings."
              .format(args_type, fpath))
        return None


def show_target_files(file_dict):
    if is_color:
        fg = FG256(2)
        end = END
    else:
        fg = ''
        end = ''
    print('{}target files{}'.format(fg, end))

    for key in sorted(file_dict.keys()):
        if py_version >= 3009 and Path(key).is_relative_to(Path.cwd()):
            src = Path(key).relative_to(Path.cwd())
        else:
            src = key
        print('{} => {}'.format(src, home_cut(file_dict[key])))
    print(fg+'=~=~=~=~=~=~=~=~=~='+end)


def main_opt(args):
    bin_dst = Path(args.prefix)/'bin'
    lib_dst = Path(args.prefix)/'lib'
    opt_src = Path(args.fpath)/'opt'
    bin_src = opt_src/'bin'
    lib_src = opt_src/'lib'
    if is_color:
        fg = FG256(10)
        end = END
    else:
        fg = ''
        end = ''
    print('\n{}@ {}{}\n'.format(fg, opt_src, end))

    files = get_files(args.setup_file, 'opt', args.prefix)
    if files is None:
        files = {}

        if args.type != 'min':
            for bfy in bin_src.glob('*'):
                if os.access(bfy, os.X_OK):
                    fname = bfy.name
                    if (fname == 'pdf2jpg'):
                        if (uname == 'Darwin'):
                            files[bfy] = bin_dst/fname
                    else:
                        files[bfy] = bin_dst/fname

            for lfy in lib_src.glob('*'):
                fname = lfy.name
                if fname == '__pycache__':
                    continue
                if not fname.endswith('pyc'):
                    files[lfy] = lib_dst/fname

    show_target_files(files)
    for fy in sorted(files.keys()):
        fcopy(opt_src.joinpath(fy), files[fy],
              link=args.link, force=args.force, test=args.test)


def main_conf(args):
    bin_dst = Path(args.prefix)/'bin'
    lib_dst = Path(args.prefix)/'lib'
    set_src = Path(args.fpath)/'config'
    if is_color:
        fg = FG256(10)
        end = END
    else:
        fg = ''
        end = ''
    print('\n{}@ {}{}\n'.format(fg, set_src, end))

    files_mac = {
                'zshrc': '~/.zshrc',
                'zlogin': '~/.zlogin',
                'zsh/alias.zsh': '~/.zsh/alias.zsh',
                'zsh/complete.zsh': '~/.zsh/complete.zsh',
                'zsh/functions.zsh': '~/.zsh/functions.zsh',
                'zsh/prompt.zsh': '~/.zsh/prompt.zsh',
                'posixShellRC': '~/.posixShellRC',
                'bashrc': '~/.bashrc',
                'matplotlibrc': '~/.matplotlib/matplotlibrc',
                'gitignore_global': '~/.gitignore_global',
                'screenrc': '~/.screenrc',
                'marp/marp_MeFtheme.css': '~/.marp/marp_MeFtheme.css',
                'tigrc':  '~/.tigrc',
                'fish': Path(args.conf_home)/'fish',
                }

    files_linux = {
                  'zshrc': '~/.zshrc',
                  'zlogin': '~/.zlogin',
                  'zsh/alias.zsh': '~/.zsh/alias.zsh',
                  'zsh/complete.zsh': '~/.zsh/complete.zsh',
                  'zsh/functions.zsh': '~/.zsh/functions.zsh',
                  'zsh/prompt.zsh': '~/.zsh/prompt.zsh',
                  'posixShellRC': '~/.posixShellRC',
                  'bashrc': '~/.bashrc',
                  'terminator_config': Path(args.conf_home)/'terminator/config',
                  'terminology_base.cfg': Path(args.conf_home)/'terminology/config/standard/base.cfg',
                  'matplotlibrc': Path(args.conf_home)/'matplotlib/matplotlibrc',
                  'gitignore_global': '~/.gitignore_global',
                  'screenrc': '~/.screenrc',
                    'fish': Path(args.conf_home)/'fish',
                }

    files_win = {}

    files_min = {
                  'posixShellRC': '~/.posixShellRC',
                  'bashrc': '~/.bashrc',
                  'gitignore_global': '~/.gitignore_global',
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
        bashdir = Path('~/.bash').expanduser()
        mkdir(bashdir)
        urlreq.urlretrieve('https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh', bashdir/'git-prompt.sh')

    show_target_files(files)
    for fy in sorted(files.keys()):
        fy_dir = Path(files[fy]).expanduser().parent
        if fy_dir.is_dir():
            fcopy(set_src.joinpath(fy), files[fy],
                  link=bool(args.link), force=args.force, test=args.test)
        else:
            print('{} does not exist, do not copy {}.'.format(fy_dir, fy))

    bash_read = 'read -p "update? (y/[n]) " YN'
    zsh_read = 'read "YN?update? (y/[n]) "'
    pyopt = '--prefix "{}"'.format(args.prefix)
    pyopt += ' --type ' + args.type
    if args.setup_file is not None:
        pyopt += ' --setup_file "{}"'.format(args.setup_file)
    if args.link:
        pyopt += ' --link'
    if args.force:
        pyopt += ' --force'
    if args.vim_prefix is not None:
        pyopt += ' --vim_prefix "{}"'.format(args.vim_prefix)
    up_stup = \
        "alias update_setup='builtin cd \"{}\"".format(args.fpath) +\
        " && git pull" +\
        " && {}" +\
        " && [[ $YN = \"y\" ]]" +\
        " && python3 setup.py {}".format(pyopt) +\
        " ; builtin cd -'"
    mine_exist = True

    if not args.test and 'zshrc' in files:
        zshrc_mine = Path('~/.zsh/zshrc.mine').expanduser()
        if not zshrc_mine.is_file():
            mkdir('~/.zsh')
            with open(zshrc_mine, 'a') as f:
                f.write('## PC dependent zshrc\n')
                f.write('#\n')
                f.write('\n')
                f.write('export PATH=\\\n"{}":\\\n$PATH'.format(bin_dst))
                f.write('\n')
                f.write('export PYTHONPATH=\\\n"{}"{}\\\n$PYTHONPATH'.format(lib_dst, psep))
                f.write('\n\n')
                f.write(up_stup.format(zsh_read))
                f.write('\n\n')
            print('made zshrc.mine')
            mine_exist = False

    if not args.test and 'bashrc' in files:
        bashrc_mine = Path('~/.bash/bashrc.mine').expanduser()
        if not bashrc_mine.is_file():
            mkdir('~/.bash')
            with open(bashrc_mine, 'a') as f:
                f.write('## PC dependent bashrc\n')
                f.write('#\n')
                f.write('\n')
                f.write('export PATH=\\\n"{}":\\\n$PATH'.format(bin_dst))
                f.write('\n')
                f.write('export PYTHONPATH=\\\n"{}"{}\\\n$PYTHONPATH'.format(lib_dst, psep))
                f.write('\n\n')
                f.write(up_stup.format(bash_read))
                f.write('\n\n')
            print('made bashrc.mine')
            mine_exist = False

    if mine_exist:
        if 'zsh' in os.environ['SHELL']:
            print('  update alias is\n{}'.format(up_stup.format(zsh_read)))
        elif 'bash' in os.environ['SHELL']:
            print('  update alias is\n{}'.format(up_stup.format(bash_read)))


def main_vim(args):
    vim_src = Path(args.fpath)/'vim'
    if is_color:
        fg = FG256(10)
        end = END
    else:
        fg = ''
        end = ''
    print('\n{}@ {}{}\n'.format(fg, vim_src, end))

    if args.vim_prefix is not None:
        vim_config_path = Path(args.vim_prefix)
        vimrc = vim_config_path/'init.vim'
    elif uname == 'Windows':
        vim_config_path = Path('~/vimfiles').expanduser()
        vimrc = Path('~/_vimrc').expanduser()
    else:
        vim_config_path = Path(args.conf_home)/'nvim'
        vimrc = vim_config_path/'init.vim'
    rc_dst = vim_config_path/'rcdir'
    ft_dst = vim_config_path/'ftplugin'
    plg_dst = vim_config_path/'plug_conf'
    al_dst = vim_config_path/'autoload'
    mkdir(vim_config_path/'swp')

    files = get_files(args.setup_file, 'vim', args.prefix)
    if files is None:
        if args.type == 'min':
            files = {'vimrc': vimrc,
                     'rcdir/vimrc_options.vim': rc_dst/'vimrc_options.vim',
                     'rcdir/vimrc_maps.vim': rc_dst/'vimrc_maps.vim',
                     'autoload/meflib.vim': al_dst/'meflib.vim',
                     'autoload/meflib/basic.vim': al_dst/'meflib'/'basic.vim',
                     }
        else:
            files = {'vimrc': vimrc}
            files[str(vim_src/'rcdir')] = rc_dst
            files[str(vim_src/'ftplugin')] = ft_dst
            files[str(vim_src/'plug_conf')] = plg_dst
            files[str(vim_src/'autoload')] = al_dst

    if args.download:
        print('\ndownload vimPlug')
        mkdir(al_dst)
        urlreq.urlretrieve('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', al_dst/'plug.vim')

    if False:  # (args.type != 'min') and args.download and chk_cmd('sh', True):
        print('\nclone dein')
        dein_path = vim_config_path/'dein'
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
        fcopy(vim_src.joinpath(fy), files[fy],
              link=args.link, force=args.force, test=args.test)

    if not uname == 'Windows':
        src = vimrc
        dst = Path('~/.vimrc').expanduser()
        if not dst.is_file():
            if not args.test:
                print("link " + src + " -> " + dst)
                os.symlink(src, dst)

        src = vim_config_path
        dst = Path('~/.vim').expanduser()
        if not dst.is_dir():
            if not args.test:
                print("link " + src + " -> " + dst)
                os.symlink(src, dst)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix', help='install directory', default=Path('~/opt').expanduser())
    parser.add_argument('--vim_prefix', help='Vim configuration directory', default=None)
    parser.add_argument('--download', help='download some files (from git)', action='store_true')
    parser.add_argument('--link', help="link files instead of copy", action='store_true')
    parser.add_argument('--test', help="don't copy, just show command", action='store_true')
    parser.add_argument('-f', '--force', help="Do not prompt for confirmation before overwriting the destination path", action='store_true')
    parser.add_argument('-t', '--type', help="set the type of copy files. If min is specified, only copy *shrc, posixShellRC, and vimrc_basic.vim.", choices='all opt config vim min'.split(), default='all')
    parser.add_argument('-s', '--setup_file', help='specify the copy files by json format setting file. please see "opt/test/setup_file_template.json" as an example.')
    args = parser.parse_args()

    if not Path(args.prefix).is_dir():
        print("install path {} does not exit".format(args.prefix))
        exit()

    fpath = Path(__file__).resolve().parent
    args.fpath = fpath
    os.chdir(fpath)

    if 'XDG_CONFIG_HOME' in os.environ:
        conf_home = os.environ['XDG_CONFIG_HOME']
    else:
        conf_home = Path('~/.config').expanduser()
    args.conf_home = conf_home

    if args.type in 'all opt min'.split():
        main_opt(args)
    if args.type in 'all config min'.split():
        main_conf(args)
    if args.type in 'all vim min'.split():
        main_vim(args)


if __name__ == "__main__":
    main()
