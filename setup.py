
import os
import sys
import argparse
import shutil
import filecmp
import difflib
import datetime
import json
import platform
import urllib.request as urlreq
from pathlib import Path

sys.path.append(str(Path(__file__).parent/'opt'/'lib'))
from pymeflib.util import mkdir
from pymeflib.color import FG256, END

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


class CopyClass():
    """ copy class
    init -> stack -> exec
    """

    def __init__(self, link: bool, force: bool, test: bool,
                 display_level_origin: int):
        self.link = link
        self.force = force
        self.test = test
        self.dl = display_level_origin
        self.cwd = Path.cwd()
        self.src = []
        self.dst = []
        self.len = 0
        self.shift = '  '
        self.dshift = '   |'
        self.ignore_list = [
                '__pycache__',
                '.git',
                'LICENSE',
                'README',
                ]

    def stack(self, src: str, dst: str):
        src = Path(src).expanduser()
        dst = Path(dst).expanduser()
        if src.is_file():
            assert dst.is_file() or not dst.exists()
            for il in self.ignore_list:
                if il in str(src):
                    self.print('[{}] ignored by [{}]'.format(src, il), 2)
                    return
            self.src.append(src)
            self.dst.append(dst)
            self.len += 1
        elif src.is_dir():
            assert dst.is_dir() or not dst.exists()
            for fy in src.glob("**/*"):
                skip = False
                if fy.is_dir():
                    continue
                for il in self.ignore_list:
                    if il in str(fy):
                        self.print('[{}] ignored by [{}]'.format(fy, il), 2)
                        skip = True
                if skip:
                    continue
                cpdir = dst/(fy.parent.relative_to(src))
                self.src.append(fy)
                self.dst.append(cpdir/(fy.name))
                self.len += 1
        else:
            self.print("No such file or directory: {}".format(src), 0)
            return

    def copy(self, src: Path, dst: Path):
        fg = FG256(11)
        end = END

        if self.link:
            if self.test:
                comment = 'cmd check:: link {} --> {}'.format(src, dst)
            else:
                comment = 'link {} --> {}'.format(src.name, self.home_cut(dst))
                os.symlink(src, dst)
        else:
            if self.test:
                comment = 'cmd check:: copy {} --> {}'.format(src, dst)
            else:
                comment = 'copy {} --> {}'.format(src.name, self.home_cut(dst))
                shutil.copy(src, dst)

        self.print('{}{}{}'.format(fg, comment, end), 0)

    def diff(self, index):
        src = self.src[index]
        dst = self.dst[index]
        # https://it-ojisan.tokyo/python-difflib/#keni_toc_2
        src_dt = datetime.datetime.fromtimestamp(src.stat().st_mtime)
        dst_dt = datetime.datetime.fromtimestamp(dst.stat().st_mtime)
        with open(src, 'r', encoding='utf-8') as f:
            src_str = f.readlines()
        with open(dst, 'r', encoding='utf-8') as f:
            dst_str = f.readlines()

        for line in difflib.unified_diff(dst_str, src_str, n=1,
                fromfile=self.home_cut(dst), tofile=self.home_cut(src),
                fromfiledate=dst_dt.strftime('%m %d (%Y) %H:%M:%S'),
                tofiledate=src_dt.strftime('%m %d (%Y) %H:%M:%S')):
            line = line.replace('\n', '')
            if line[0] == '+':
                col = FG256(12)
                end = END
            elif line[0] == '-':
                col = FG256(1)
                end = END
            else:
                col = ''
                end = ''
            self.print(self.dshift+col+line+end, 0)

    def print(self, string: str, display_level: int):
        # display_level;
        #   2 ... shown only if all messages are shown
        #   1 ... shown in usual case
        #   0 ... shown always
        if self.dl >= display_level:
            print(string)

    def dst_check(self, index):
        src = self.src[index]
        dst = self.dst[index]
        dst2 = self.home_cut(dst)
        if dst.exists():
            exist = True
            cmp = filecmp.cmp(src, dst)
        else:
            exist = False
            cmp = False
        islink = dst.is_symlink()

        if exist:
            if islink and cmp:
                self.print(self.shift+'[ {} ] is already linked.'.format(dst2),
                           2)
            elif islink:
                self.print(self.shift +
                           '[ {} ] is another link file.'.format(dst2), 2)
            elif cmp:
                self.print(self.shift+'[ {} ] is already copied.'.format(dst2),
                           2)
            else:
                if self.force:
                    dl = 2
                else:
                    dl = 0
                self.print(self.shift +
                           '[ {} ] is already existed.'.format(dst2), dl)
        else:
            if islink:
                # broken link
                linkpath = dst.parent.joinpath(dst.readlink())
                os.unlink(dst)
                self.print('{}{} -> {} is a broken link. unlink.{}'.format(
                    FG256(1), dst2, self.home_cut(linkpath), END), 0)
                exist = False
                islink = False
                cmp = False

        return exist, islink, cmp

    def diff_check(self, index):
        src = self.src[index]
        is_diff = False
        while True:
            if is_diff:
                input_str = self.shift +\
                 'are you really overwrite? [y(yes), n(no)] '
            else:
                input_str = self.shift +\
                 'are you really overwrite? [y(yes), n(no), d(diff)] '
            yn = input(input_str)
            if yn in ['y', 'yes']:
                return True
            elif yn in ['d', 'diff'] and not is_diff:
                self.print('', 0)
                self.diff(index)
                self.print('', 0)
                is_diff = True
            elif yn in ['n', 'no']:
                self.print('Do not copy '+src.name, 0)
                return False

    def show_files(self):
        fg = FG256(2)
        end = END
        self.print('{}target files{}'.format(fg, end), 1)

        for i in range(self.len):
            if py_version >= 3009 and \
               self.src[i].is_relative_to(self.cwd):
                src = self.src[i].relative_to(self.cwd)
            else:
                src = self.src[i]
            self.print('{} => {}'.format(src, self.home_cut(self.dst[i])), 1)
        self.print(fg+'=~=~=~=~=~=~=~=~=~='+end, 1)

    def home_cut(self, path: Path):
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

    def exec(self):
        for i in range(self.len):
            src = self.src[i]
            dst = self.dst[i]
            dst_dir = dst.parent
            if self.test:
                if not dst_dir.is_dir():
                    self.print('process check:: mkdir {}'.format(dst_dir), 0)
            else:
                mkdir(dst_dir)

            exist, islink, cmp = self.dst_check(i)

            if not exist:
                self.copy(src, dst)
            else:
                if not self.link:
                    if cmp:
                        continue
                    elif self.force and not islink:
                        self.print(self.shift+'overwrite;', 0)
                        self.copy(src, dst)
                    else:
                        if self.diff_check(i):
                            self.copy(src, dst)


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


def main_opt(args):
    bin_dst = Path(args.prefix)/'bin'
    lib_dst = Path(args.prefix)/'lib'
    opt_src = Path(args.fpath)/'opt'
    bin_src = opt_src/'bin'
    lib_src = opt_src/'lib'
    fg = FG256(10)
    end = END
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

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   display_level_origin=args.display_level)
    for fy in sorted(files.keys()):
        cc.stack(opt_src.joinpath(fy), files[fy])
    cc.show_files()
    cc.exec()
    local_conf_dir = Path(args.conf_home)/'meflib'
    if not local_conf_dir.exists():
        os.makedirs(local_conf_dir)
        print('mkdir: {}'.format(local_conf_dir))


def main_conf(args):
    bin_dst = Path(args.prefix)/'bin'
    lib_dst = Path(args.prefix)/'lib'
    set_src = Path(args.fpath)/'config'
    local_conf_dir = Path(args.conf_home)/'meflib'
    if not local_conf_dir.exists():
        os.makedirs(local_conf_dir)
        print('mkdir: {}'.format(local_conf_dir))
    fg = FG256(10)
    end = END
    print('\n{}@ {}{}\n'.format(fg, set_src, end))

    files_mac = {
                'zshrc': '~/.zshrc',
                'zlogin': '~/.zlogin',
                'zsh': '~/.zsh',
                'posixShellRC': '~/.posixShellRC',
                'bashrc': '~/.bashrc',
                'bash': '~/.bash',
                'matplotlibrc': '~/.matplotlib/matplotlibrc',
                'gitignore_global': '~/.gitignore_global',
                'screenrc': '~/.screenrc',
                'marp/marp_MeFtheme.css': '~/.marp/marp_MeFtheme.css',
                'tigrc':  '~/.tigrc',
                'fish/config.fish': Path(args.conf_home)/'fish/config.fish',
                'fish/functions': Path(args.conf_home)/'fish/functions',
                }

    files_linux = {
                  'zshrc': '~/.zshrc',
                  'zlogin': '~/.zlogin',
                  'zsh': '~/.zsh',
                  'posixShellRC': '~/.posixShellRC',
                  'bashrc': '~/.bashrc',
                  'bash': '~/.bash',
                  'matplotlibrc': Path(args.conf_home)/'matplotlib/matplotlibrc',
                  'gitignore_global': '~/.gitignore_global',
                  'screenrc': '~/.screenrc',
                  'fish/config.fish': Path(args.conf_home)/'fish/config.fish',
                  'fish/functions': Path(args.conf_home)/'fish/functions',
                }

    files_win = {}

    files_min = {
                  'posixShellRC': '~/.posixShellRC',
                  'bashrc': '~/.bashrc',
                  'bash': '~/.bash',
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

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   display_level_origin=args.display_level)
    for fy in sorted(files.keys()):
        fy_dir = Path(files[fy]).expanduser().parent
        if fy_dir.is_dir():
            cc.stack(set_src.joinpath(fy), files[fy])
        else:
            print('{} does not exist, do not copy {}.'.format(fy_dir, fy))
    cc.show_files()
    cc.exec()

    pyopt = '--prefix "{}"'.format(args.prefix)
    pyopt += ' --type ' + args.type
    pyopt += ' --display_level ' + str(args.display_level)
    if args.setup_file is not None:
        pyopt += ' --setup_file "{}"'.format(args.setup_file)
    if args.link:
        pyopt += ' --link'
    if args.force:
        pyopt += ' --force'
    if args.vim_prefix is not None:
        pyopt += ' --vim_prefix "{}"'.format(args.vim_prefix)
    update_setup = """#! /bin/bash

if [[ -d "$TMPDIR" ]]; then
    tmpfile="${{TMPDIR}}/update_setup"
else
    echo "TMPDIR is not found. use config dir."
    tmpfile="{}/update_setup"
fi
echo '
#! /bin/bash
close()
{{
    if [[ -n "$moved" ]]; then
        echo "go back"
        builtin cd -
    fi
}}
if [[ "$PWD" != "{}" ]]; then
    echo "cd {}"
    builtin cd "{}"
    moved="true"
fi
if [[ "$1" != "--nopull" ]]; then
    echo "pull ..."
    git pull
    if [[ $? != 0 ]]; then
        close
        exit
    fi
    echo "submodule update ..."
    git submodule update
    if [[ $? != 0 ]]; then
        close
        exit
    fi
fi
read -p "update? (y/[n]) " YN
if [[ "${{YN}}" = "y" ]]; then
    python3 setup.py {}
fi
close
' > $tmpfile
chmod u+x $tmpfile
$tmpfile $1
# vim:ft=sh
""".format(local_conf_dir, args.fpath, args.fpath, args.fpath, pyopt)
    if bin_dst.is_dir():
        if args.test:
            print('create update_setup in {}'.format(bin_dst))
        else:
            print('creating update_setup file in {} ...'.format(bin_dst))
            update_setup_file = bin_dst/'update_setup'
            with open(update_setup_file, 'w') as f:
                f.write(update_setup)
            update_setup_file.chmod(0o744)
            print('done')
    else:
        print('{} is not found. update_setup is not created'.format(bin_dst))

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
            print('made zshrc.mine')

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
            print('made bashrc.mine')


def main_vim(args):
    vim_src = Path(args.fpath)/'vim'
    fg = FG256(10)
    end = END
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
    doc_dst = vim_config_path/'doc'
    aft_dst = vim_config_path/'after'
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
            files[str(vim_src/'doc')] = doc_dst
            files[str(vim_src/'after')] = aft_dst

    if args.download:
        print('\ndownload vimPlug')
        mkdir(al_dst)
        urlreq.urlretrieve('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', al_dst/'plug.vim')

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   display_level_origin=args.display_level)
    for fy in sorted(files.keys()):
        cc.stack(vim_src.joinpath(fy), files[fy])
    cc.show_files()
    cc.exec()

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
    parser.add_argument('--prefix', help='install directory',
                        default=Path('~/workspace/opt').expanduser())
    parser.add_argument('--vim_prefix', help='Vim configuration directory',
                        default=None)
    parser.add_argument('--download', help='download some files (from git)',
                        action='store_true')
    parser.add_argument('--link', help="link files instead of copy",
                        action='store_true')
    parser.add_argument('--test', help="don't copy, just show command",
                        action='store_true')
    parser.add_argument('-f', '--force',
                        help="Do not prompt for confirmation before overwriting the destination path",
                        action='store_true')
    parser.add_argument('-t', '--type',
                        help="set the type of copy files. If min is specified, only copy *shrc, posixShellRC, and vimrc_basic.vim.",
                        choices='all opt config vim min'.split(), default='all')
    parser.add_argument('-s', '--setup_file',
                        help='specify the copy files by json format setting file. please see "opt/test/setup_file_template.json" as an example.')
    parser.add_argument('-d', '--display_level', choices=[0, 1, 2],
                        help='set the diaplay level. 0=only executed process, 1=target files and executed process (default), 2=all',
                        type=int, default=1)
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
