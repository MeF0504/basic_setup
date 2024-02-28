
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
from typing import List, Optional, Literal, Union
from dataclasses import dataclass

try:
    from send2trash import send2trash
except ImportError as e:
    print(e)
    is_import_trash = False
else:
    is_import_trash = True

sys.path.append(str(Path(__file__).parent/'opt'/'lib'))
from pymeflib.util import mkdir, chk_cmd
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

colors = {
        "message": 11,
        "diff_plus": 12,
        "diff_minus": 1,
        "error": 1,
        "show_files": 2,
        "path": 10,
        }

TypeList = Literal["all", "opt", "config", "vim"]


@dataclass
class Args:
    """
    wrapper of argument parser.
    useful for organizing information of args.
    """
    prefix: Optional[Path]
    vim_prefix: Optional[Path]
    download: bool
    link: bool
    test: bool
    force: bool
    type: List[TypeList]
    setup_file: Optional[str]
    clear: bool
    show_target_files: bool
    show_no_update_files: bool
    show_all: bool

    fpath: Path
    conf_home: Path
    opt_src: Path
    bin_src: Path
    lib_src: Path
    bin_dst: Optional[Path]
    lib_dst: Optional[Path]
    conf_src: Path
    vim_src: Path
    vim_conf: Path
    vimrc: Path
    rc_dst: Path
    ft_dst: Path
    plg_dst: Path
    al_dst: Path
    doc_dst: Path
    aft_dst: Path
    local_conf: Path


class CopyClass():
    """ copy class
    init -> stack -> exec
    """

    def __init__(self, link: bool, force: bool, test: bool,
                 show_target: bool, show_no_update: bool,
                 show_all: bool):
        self.link = link
        self.force = force
        self.test = test
        self.show_target = show_target or show_all
        self.show_no_update = show_no_update or show_all
        self.show_all = show_all
        self.cwd = Path.cwd()
        self.src: List[Path] = []
        self.dst: List[Path] = []
        self.len = 0
        self.shift = '  '
        self.dshift = '   |'
        self.ignore_list = [
                '__pycache__',
                '.git',
                'LICENSE',
                'README',
                ]

    def stack(self, src_str: str, dst_str: str):
        src = Path(src_str).expanduser()
        dst = Path(dst_str).expanduser()
        if src.is_file():
            assert dst.is_file() or not dst.exists()
            for il in self.ignore_list:
                if il in str(src):
                    self.print('[{}] ignored by [{}]'.format(src, il),
                               self.show_all)
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
                        self.print('[{}] ignored by [{}]'.format(fy, il),
                                   self.show_all)
                        skip = True
                if skip:
                    continue
                cpdir = dst/(fy.parent.relative_to(src))
                self.src.append(fy)
                self.dst.append(cpdir/(fy.name))
                self.len += 1
        else:
            self.print("No such file or directory: {}".format(src), True)
            return

    def copy(self, src: Path, dst: Path):
        fg = FG256(colors['message'])
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

        self.print('{}{}{}'.format(fg, comment, end), True)

    def diff(self, index: int):
        src = self.src[index]
        dst = self.dst[index]
        # https://it-ojisan.tokyo/python-difflib/#keni_toc_2
        src_dt = datetime.datetime.fromtimestamp(src.stat().st_mtime)
        dst_dt = datetime.datetime.fromtimestamp(dst.stat().st_mtime)
        with open(src, 'r', encoding='utf-8') as f:
            src_str = f.readlines()
        with open(dst, 'r', encoding='utf-8') as f:
            dst_str = f.readlines()

        dst_date = dst_dt.strftime('%m %d (%Y) %H:%M:%S')
        src_date = src_dt.strftime('%m %d (%Y) %H:%M:%S')
        dlines = difflib.unified_diff(dst_str, src_str, n=1,
                                      fromfile=self.home_cut(dst),
                                      tofile=self.home_cut(src),
                                      fromfiledate=dst_date,
                                      tofiledate=src_date)
        for line in dlines:
            line = line.replace('\n', '')
            if line[0] == '+':
                col = FG256(colors['diff_plus'])
                end = END
            elif line[0] == '-':
                col = FG256(colors['diff_minus'])
                end = END
            else:
                col = ''
                end = ''
            self.print(self.dshift+col+line+end, True)

    def print(self, string: str, show: bool):
        if show:
            print(string)

    def dst_check(self, index: int):
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
                           self.show_no_update)
            elif islink:
                self.print(self.shift +
                           '[ {} ] is another link file.'.format(dst2),
                           self.show_no_update)
            elif cmp:
                self.print(self.shift+'[ {} ] is already copied.'.format(dst2),
                           self.show_no_update)
            else:
                if self.force:
                    show_cmt = self.show_all
                else:
                    show_cmt = True
                self.print(self.shift +
                           '[ {} ] is already existed.'.format(dst2), show_cmt)
        else:
            if islink:
                # broken link
                linkpath = dst.parent.joinpath(dst.readlink())
                os.unlink(dst)
                self.print('{}{} -> {} is a broken link. unlink.{}'.format(
                    FG256(colors['error']), dst2,
                    self.home_cut(linkpath), END), True)
                exist = False
                islink = False
                cmp = False

        return exist, islink, cmp

    def diff_check(self, index: int):
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
                self.print('', True)
                self.diff(index)
                self.print('', True)
                is_diff = True
            elif yn in ['n', 'no']:
                self.print('Do not copy '+src.name, True)
                return False

    def show_files(self):
        fg = FG256(colors['show_files'])
        end = END
        self.print('{}target files{}'.format(fg, end), self.show_target)

        for i in range(self.len):
            if py_version >= 3009 and \
               self.src[i].is_relative_to(self.cwd):
                src = self.src[i].relative_to(self.cwd)
            else:
                src = self.src[i]
            self.print('{} => {}'.format(src, self.home_cut(self.dst[i])),
                       self.show_target)
        self.print(fg+'=~=~=~=~=~=~=~=~=~='+end, self.show_target)

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
                    self.print('process check:: mkdir {}'.format(dst_dir),
                               True)
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
                        self.print(self.shift+'overwrite the following file;',
                                   True)
                        self.copy(src, dst)
                    elif islink:
                        continue
                    else:
                        if self.diff_check(i):
                            self.copy(src, dst)

    def clear(self, root: str, append_files: List[Path] = []):
        clear_files = []
        dsts = self.dst + append_files
        for f in Path(root).glob('**/*'):
            if f.is_dir():
                continue
            elif f.is_symlink():
                if not f.exists():
                    # broken link
                    clear_files.append(f)
                elif f in dsts or f.parent.joinpath(f.readlink()) in dsts:
                    continue
                else:
                    # not in dst
                    clear_files.append(f)
            else:
                if f not in dsts:
                    clear_files.append(f)

        for f in clear_files:
            if f.is_symlink():
                if self.test:
                    self.print(f'process check::unlink {f}', True)
                else:
                    yn = input(f'unlink {f}? ([y]/n): ')
                    if yn != 'n':
                        os.unlink(f)
            else:
                if is_import_trash:
                    if self.test:
                        self.print(f'process check::move {f} to Trash', True)
                    else:
                        yn = input(f'move {f} to Trash? ([y]/n): ')
                        if yn != 'n':
                            send2trash(f)
                else:
                    if self.test:
                        self.print(f'process check::remove {f}', True)
                    else:
                        yn = input(f'remove {f}? ([y]/n): ')
                        if yn != 'n':
                            os.remove(f)


def print_path(path: Union[str, Path]):
    fg = FG256(colors['path'])
    end = END
    print('\n{}@ {}{}\n'.format(fg, path, end))


def get_files(setup_path: Optional[str],
              args_type: TypeList, prefix: Optional[str]):
    if setup_path is None:
        return None

    fpath = Path(setup_path).expanduser()
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
                if prefix is None:
                    print('prefix is None: skip {}'.format(src))
                    continue
                dest = dest.replace('$PREFIX', prefix)
            res_files[src] = dest
        return res_files
    else:
        print("{} is not in {}. use default settings."
              .format(args_type, fpath))
        return None


def set_path(args: Args):
    if 'XDG_CONFIG_HOME' in os.environ:
        conf_home = Path(os.environ['XDG_CONFIG_HOME'])
    else:
        conf_home = Path('~/.config').expanduser()
    args.conf_home = conf_home

    args.opt_src = args.fpath/'opt'
    args.bin_src = args.opt_src/'bin'
    args.lib_src = args.opt_src/'lib'
    if args.prefix is None:
        args.bin_dst = None
        args.lib_dst = None
    else:
        args.bin_dst = Path(args.prefix)/'bin'
        args.lib_dst = Path(args.prefix)/'lib'

    args.conf_src = args.fpath/'config'

    args.vim_src = args.fpath/'vim'
    if args.vim_prefix is not None:
        args.vim_conf = Path(args.vim_prefix)
        args.vimrc = args.vim_conf/'init.vim'
    elif uname == 'Windows':
        args.vim_conf = Path('~/vimfiles').expanduser()
        args.vimrc = Path('~/_vimrc').expanduser()
    else:
        args.vim_conf = Path(args.conf_home)/'nvim'
        args.vimrc = args.vim_conf/'init.vim'
    args.rc_dst = args.vim_conf/'rcdir'
    args.ft_dst = args.vim_conf/'ftplugin'
    args.plg_dst = args.vim_conf/'plug_conf'
    args.al_dst = args.vim_conf/'autoload'
    args.doc_dst = args.vim_conf/'doc'
    args.aft_dst = args.vim_conf/'after'

    local_conf = Path(args.conf_home)/'meflib'
    if not local_conf.exists():
        try:
            os.makedirs(local_conf)
            print('mkdir: {}'.format(local_conf))
        except Exception as e:
            print('failed to make conf dir: {}'.format(local_conf))
            print('error: {}'.format(e))
    args.local_conf = local_conf


def set_color(args: Args):
    if args.setup_file is None:
        return
    setfile = Path(args.setup_file)
    if not setfile.is_file():
        return

    global colors
    with open(setfile, 'r') as f:
        conf = json.load(f)
        if 'color' in conf:
            color_conf = conf['color']
            for key in colors:
                if key in color_conf:
                    if type(color_conf[key]) is int and \
                       0 <= color_conf[key] < 256:
                        colors[key] = color_conf[key]


def create_update(args: Args):
    if args.bin_dst is None:
        return
    if not args.bin_dst.is_dir():
        print(f'{args.bin_dst} is not found. update_setup is not created')
        return

    pyopt = ''
    if args.prefix is not None:
        pyopt += '--prefix "{}"'.format(args.prefix)
    pyopt += ' --type ' + ' '.join(args.type)
    if args.setup_file is not None:
        pyopt += ' --setup_file "{}"'.format(args.setup_file)
    if args.link:
        pyopt += ' --link'
    if args.force:
        pyopt += ' --force'
    if args.vim_prefix is not None:
        pyopt += ' --vim_prefix "{}"'.format(args.vim_prefix)
    if args.show_all:
        pyopt += ' --show_all'
    if args.show_target_files:
        pyopt += ' --show_target_files'
    if args.show_no_update_files:
        pyopt += ' --show_no_update_files'
    if args.clear:
        pyopt += ' --clear'
    with open(args.fpath/'opt/samples/update_setup_sample.py', 'r') as f:
        update_setup = f.read().format(args.fpath, args.fpath, args.fpath,
                                       pyopt).replace('\\', '\\\\')

    update_setup_file = args.bin_dst/'update_setup'
    if update_setup_file.is_file():
        create_us = False
        cur_update_setup = []
        with open(update_setup_file, 'r') as f:
            cur_update_setup = f.readlines()
            cur_update_setup = [line.replace('\n', '')
                                for line in cur_update_setup]
            # I don't know why but it looks like
            # empty line is appended.
            cur_update_setup += ['']
        if cur_update_setup != update_setup.split('\n'):
            create_us = True
            us_diff = difflib.unified_diff(cur_update_setup,
                                           update_setup.split('\n'),
                                           fromfile='current script',
                                           tofile='created script')
    else:
        create_us = True
        us_diff = []

    if create_us:
        if args.test:
            print('create update_setup in {}'.format(args.bin_dst))
            print('---- diff -----')
            for line in us_diff:
                print(line.replace('\n', ''))
            print('---------------')
        else:
            print('creating update_setup file in {} ...'.format(args.bin_dst))
            print('---- diff -----')
            for line in us_diff:
                print(line.replace('\n', ''))
            print('---------------')
            with open(update_setup_file, 'w') as f:
                f.write(update_setup)
            update_setup_file.chmod(0o744)
            print('done')
            if uname == 'Windows':
                # for .qrun_conf.vim
                mkdir('tmp')
                shutil.copy(update_setup_file, Path('tmp')/'update_setup')


def main_opt(args: Args):
    if args.prefix is None:
        return
    print_path(args.opt_src)

    files = get_files(args.setup_file, 'opt', args.prefix)
    if files is None:
        files = {}
        for bfy in args.bin_src.glob('*'):
            if os.access(bfy, os.X_OK):
                fname = bfy.name
                if (fname == 'pdf2jpg'):
                    if (uname == 'Darwin'):
                        files[bfy] = args.bin_dst/fname
                else:
                    files[bfy] = args.bin_dst/fname

        for lfy in args.lib_src.glob('*'):
            fname = lfy.name
            if fname == '__pycache__':
                continue
            if not fname.endswith('pyc'):
                files[lfy] = args.lib_dst/fname

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   show_target=args.show_target_files,
                   show_no_update=args.show_no_update_files,
                   show_all=args.show_all)
    for fy in sorted(files.keys()):
        cc.stack(args.opt_src.joinpath(fy), files[fy])
    cc.show_files()
    cc.exec()
    # opt は関係ないbin, libもあるのでclearは呼ばない


def main_conf(args: Args):
    print_path(args.conf_src)

    files_mac = {
                'zsh/zshrc': '~/.zshrc',
                'zsh/zlogin': '~/.zlogin',
                'zsh/zsh': '~/.zsh',
                'tmp/zshrc.mine': '~/.zsh/zshrc.mine',
                'shell/posixShellRC': '~/.posixShellRC',
                'shell/psfuncs/get_zodiac_whgm.sh': args.local_conf/'get_zodiac_whgm.sh',
                'shell/psfuncs/today_percentage.sh': args.local_conf/'today_percentage.sh',
                'bash/bashrc': '~/.bashrc',
                'bash/bash': '~/.bash',
                'tmp/bashrc.mine': '~/.bash/bashrc.mine',
                'matplotlibrc': '~/.matplotlib/matplotlibrc',
                'git/gitignore_global': '~/.gitignore_global',
                'screenrc': '~/.screenrc',
                'marp/marp_MeFtheme.css': '~/.marp/marp_MeFtheme.css',
                'git/tigrc':  '~/.tigrc',
                'fish/config.fish': Path(args.conf_home)/'fish/config.fish',
                'fish/functions': Path(args.conf_home)/'fish/functions',
                }

    files_linux = {
                  'zsh/zshrc': '~/.zshrc',
                  'zsh/zlogin': '~/.zlogin',
                  'zsh/zsh': '~/.zsh',
                  'tmp/zshrc.mine': '~/.zsh/zshrc.mine',
                  'shell/posixShellRC': '~/.posixShellRC',
                  'shell/psfuncs/get_zodiac_whgm.sh': args.local_conf/'get_zodiac_whgm.sh',
                  'shell/psfuncs/today_percentage.sh': args.local_conf/'today_percentage.sh',
                  'bash/bashrc': '~/.bashrc',
                  'bash/bash': '~/.bash',
                  'tmp/bashrc.mine': '~/.bash/bashrc.mine',
                  'matplotlibrc': Path(args.conf_home)/'matplotlib/matplotlibrc',
                  'git/gitignore_global': '~/.gitignore_global',
                  'screenrc': '~/.screenrc',
                  'git/tigrc':  '~/.tigrc',
                  'fish/config.fish': Path(args.conf_home)/'fish/config.fish',
                  'fish/functions': Path(args.conf_home)/'fish/functions',
                }

    files_win = {}

    files = get_files(args.setup_file, 'config', args.prefix)
    if files is None:
        if uname == 'Darwin':
            files = files_mac
        elif uname == 'Linux':
            files = files_linux
        elif uname == 'Windows':
            files = files_win
        else:
            files = {}

    if args.download:
        print('download git-prompt for bash')
        try:
            bashdir = Path('~/.bash').expanduser()
            mkdir(bashdir)
            urlreq.urlretrieve('https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh', bashdir/'git-prompt.sh')
        except Exception as e:
            print('failed to download git-prompt')
            print('error: {}'.format(e))

    # create ~.mine files
    if not args.test:
        for shell in 'bash zsh'.split():
            mine_src = 'tmp/{}rc.mine'.format(shell)
            if mine_src in files:
                if not Path(files[mine_src]).expanduser().is_file():
                    mine_src_path = args.conf_src/mine_src
                    mkdir(str(mine_src_path.parent))
                    with open(mine_src_path, 'w') as f:
                        f.write('## PC dependent {}rc\n'.format(shell))
                        f.write('#\n')
                        f.write('\n')
                        if args.bin_dst is not None:
                            f.write('export PATH=\\\n"{}":\\\n$PATH'.format(args.bin_dst))
                            f.write('\n')
                        if args.lib_dst is not None:
                            f.write('export PYTHONPATH=\\\n"{}"{}\\\n$PYTHONPATH'.format(args.lib_dst, psep))
                            f.write('\n')
                        f.write('\n')
                    print('made {}rc.mine'.format(shell))
                else:
                    print('{}rc.mine is already exists'.format(shell))
                    files.pop(mine_src)

        # create tigrc.mine
        if 'git/tigrc' in files:
            tigrc = Path('~/.tig/tigrc.mine').expanduser()
            if not tigrc.parent.is_dir():
                mkdir(tigrc.parent)
            if not tigrc.is_file():
                with open(tigrc, 'w') as f:
                    f.write('# user local tigrc\n')
                    if chk_cmd('diff-highlight'):
                        f.write('''
# diff-highlight を使う
set diff-highlight = true
''')
                print('made tigrc.mine')

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   show_target=args.show_target_files,
                   show_no_update=args.show_no_update_files,
                   show_all=args.show_all)
    for fy in sorted(files.keys()):
        fy_dir = Path(files[fy]).expanduser().parent
        if fy_dir.is_dir():
            cc.stack(args.conf_src.joinpath(fy), files[fy])
        else:
            print('{} does not exist, do not copy {}.'.format(fy_dir, fy))
    cc.show_files()
    cc.exec()
    if args.clear:
        cc.clear(args.local_conf,
                 [args.local_conf/'shows_config.json'])
        zshdir = Path('~/.zsh').expanduser()
        bashdir = Path('~/.bash').expanduser()
        cc.clear(str(zshdir), [zshdir/'zshrc.mine',
                               zshdir/'zlogin.mine', zshdir/'enter.zsh'])
        cc.clear(str(bashdir), [bashdir/'bashrc.mine',
                                bashdir/'git-prompt.sh'])

    # create update_setup file
    create_update(args)


def main_vim(args: Args):
    print_path(args.vim_src)
    mkdir(args.vim_conf/'swp')

    files = get_files(args.setup_file, 'vim', args.prefix)
    if files is None:
        files = {'vimrc': args.vimrc}
        files[str(args.vim_src/'rcdir')] = args.rc_dst
        files[str(args.vim_src/'ftplugin')] = args.ft_dst
        files[str(args.vim_src/'plug_conf')] = args.plg_dst
        files[str(args.vim_src/'autoload')] = args.al_dst
        files[str(args.vim_src/'doc')] = args.doc_dst
        files[str(args.vim_src/'after')] = args.aft_dst

    if args.download:
        print('\ndownload vimPlug')
        mkdir(args.al_dst)
        urlreq.urlretrieve('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', args.al_dst/'plug.vim')

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   show_target=args.show_target_files,
                   show_no_update=args.show_no_update_files,
                   show_all=args.show_all)
    for fy in sorted(files.keys()):
        cc.stack(args.vim_src.joinpath(fy), files[fy])
    cc.show_files()
    cc.exec()
    if args.clear:
        cc.clear(str(args.vim_conf/'rcdir'),
                 [args.rc_dst/'vimrc_mine.post', args.rc_dst/'vimrc_mine.pre'])
        cc.clear(str(args.vim_conf/'plug_conf'))

    if not uname == 'Windows':
        src = args.vimrc
        dst = Path('~/.vimrc').expanduser()
        if src.is_file() and not dst.is_file():
            if not args.test:
                print("link {} -> {}".format(src, dst))
                try:
                    os.symlink(src, dst)
                except Exception as e:
                    print('failed to link vimrc.')
                    print('error: {}'.format(e))

        src = args.vim_conf
        dst = Path('~/.vim').expanduser()
        if src.is_dir() and not dst.is_dir():
            if not args.test:
                print("link {} -> {}".format(src, dst))
                try:
                    os.symlink(src, dst)
                except Exception as e:
                    print('failed to link vim dir.')
                    print('error: {}'.format(e))


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
    parser.add_argument('-t', '--type', nargs='*',
                        help="set the type of copy files.",
                        choices='all opt config vim'.split(), default=['all'])
    parser.add_argument('-s', '--setup_file',
                        help='specify the copy files by json format setting file. please see "opt/samples/setup_file_template.json" as an example.')
    parser.add_argument('-c', '--clear', action='store_true',
                        help='clear unused files')
    parser.add_argument('--show_target_files', action='store_true',
                        help='show target_files before copying')
    parser.add_argument('--show_no_update_files', action='store_true',
                        help='show messages "the file is already copied or linked"')
    parser.add_argument('--show_all', action='store_true',
                        help='show all messages')
    args = parser.parse_args()

    if not Path(args.prefix).is_dir():
        print("install path {} does not exit".format(args.prefix))
        args.prefix = None

    fpath = Path(__file__).resolve().parent
    args.fpath = fpath
    os.chdir(fpath)
    set_path(args)
    set_color(args)

    if 'all' in args.type:
        main_opt(args)
        main_conf(args)
        main_vim(args)
    else:
        for t in args.type:
            if t == 'opt':
                main_opt(args)
            elif t == 'config':
                main_conf(args)
            elif t == 'vim':
                main_vim(args)


if __name__ == "__main__":
    main()
