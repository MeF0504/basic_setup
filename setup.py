from __future__ import annotations

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
from typing import Literal, Any
from dataclasses import dataclass
import subprocess
_py_version = sys.version_info.major*1000 + sys.version_info.minor
if _py_version < 3006:
    print('Version >= 3.6 required')
    sys.exit()
if _py_version < 3011:
    print('use tomli')
    import tomli as tomllib
else:
    import tomllib

try:
    from send2trash import send2trash
except ImportError as e:
    print(e)
    is_import_trash = False
else:
    is_import_trash = True

try:
    from pymeflib.util import mkdir, chk_cmd
    from pymeflib.color import FG256, END
except ImportError:
    print('download pymeflib')
    cmd = ['pip3', 'install', 'git+https://github.com/MeF0504/pymeflib']
    subprocess.run(cmd)
    from pymeflib.util import mkdir, chk_cmd
    from pymeflib.color import FG256, END


uname = platform.system()
if uname == 'Windows':
    psep = ';'
else:
    psep = ':'

if 'XDG_CONFIG_HOME' in os.environ:
    CONF_HOME = Path(os.environ['XDG_CONFIG_HOME'])
else:
    CONF_HOME = Path('~/.config').expanduser()
SFILE = CONF_HOME/'meflib/setting.toml'
ROOT = Path(__file__).resolve().parent.relative_to(os.getcwd())

COLORS = {}
# COLORS = {
#         "message": 11,
#         "diff_plus": 12,
#         "diff_minus": 1,
#         "error": 1,
#         "show_files": 2,
#         "path": 10,
#         }

# ignore_files = []

TypeList = Literal["all", "opt", "config", "vim"]


@dataclass
class Args:
    """
    wrapper of argument parser.
    useful for organizing information of args.

    Parameters
    ----------
    opt_prefix: str or None
        value of --opt_prefix option.
        set the path where files in the "opt" directory are placed.
    vim_prefix: str or None
        value of --vim_prefix option.
        set the path where files in the "vim" directory are placed.
    download: bool
        value of --download option.
        download some third-party files.
    link: bool
        value of --link option.
        not copy but link files.
    test: bool
        value of --test option.
        test the setup.py file. if true, do not copy/link files,
        but display messages.
    force: bool
        value of --force option.
        if true, do not ask overwrite or not.
    type: list[TypeList]
        value of --type option.
        set types of copy/link files.
    clear: bool
        value of --clear option.
        if true, clear unused files.
    verbose: int
        count of --verbose (-v) option.
        if 0, show minimal information.
        if 1, show messages "the file is already copied or linked"
        if 2, show target_files before copying adding to above information.
        if 3, show all information.
    """

    # prefix: str | None
    opt_prefix: str | None
    vim_prefix: str | None
    download: bool
    link: bool
    test: bool
    force: bool
    type: list[TypeList]
    # setup_file: str | None
    clear: bool
    verbose: int

    # fpath: Path
    # conf_home: Path
    # opt_src: Path
    # bin_src: Path
    # lib_src: Path
    # bin_dst: Path | None
    # lib_dst: Path | None
    # conf_src: Path
    # vim_src: Path
    # vim_conf: Path
    # vimrc: Path
    # rc_dst: Path
    # ft_dst: Path
    # plg_dst: Path
    # al_dst: Path
    # doc_dst: Path
    # aft_dst: Path
    # local_conf: Path


class CopyClass():
    """ copy class
    init -> stack -> exec
    """

    def __init__(self, link: bool, force: bool, test: bool, verbose: int):
        self.link = link
        self.force = force
        self.test = test
        self.verbose = verbose
        self.py_version = _py_version
        self.cwd = Path.cwd()
        self.src: list[Path] = []
        self.dst: list[Path] = []
        self.len = 0
        self.shift = '  '
        self.dshift = '   |'
        # self.ignore_list = [
        #         '__pycache__',
        #         '.git',
        #         'LICENSE',
        #         'README',
        #         ]

    def stack(self, src_str: str, dst_str: str):
        src = Path(src_str).expanduser()
        dst = Path(dst_str).expanduser()
        if src.is_file():
            assert dst.is_file() or not dst.exists()
            # for il in self.ignore_list:
            #     if il in str(src):
            #         self.print(f'[{src}] ignored by [{il}]', 3)
            #         return
            self.src.append(src)
            self.dst.append(dst)
            self.len += 1
        elif src.is_dir():
            self.print_warn(f"{src} is a directory.", 0)
            # assert dst.is_dir() or not dst.exists()
            # for fy in src.glob("**/*"):
            #     skip = False
            #     if fy.is_dir():
            #         continue
            #     for il in self.ignore_list:
            #         if il in str(fy):
            #             self.print(f'[{fy}] ignored by [{il}]', 3)
            #             skip = True
            #     if skip:
            #         continue
            #     cpdir = dst/(fy.parent.relative_to(src))
            #     self.src.append(fy)
            #     self.dst.append(cpdir/(fy.name))
            #     self.len += 1
        else:
            self.print(f"No such file or directory: {src}", 0)
            return

    def copy(self, src: Path, dst: Path):
        fg, end = get_color('message')

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

        self.print(f'{fg}{comment}{end}', 0)

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
                col, end = get_color('diff_plus')
            elif line[0] == '-':
                col, end = get_color('diff_minus')
            else:
                col = ''
                end = ''
            self.print(self.dshift+col+line+end, 0)

    def print(self, string: str, showlevel: int):
        if self.verbose >= showlevel:
            print(string)

    def print_warn(self, string: str, showlevel: int):
        if self.verbose >= showlevel:
            print_warn(string)

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
                self.print(self.shift+f'[ {dst2} ] is already linked.', 1)
            elif islink:
                self.print(self.shift+f'[ {dst2} ] is another link file.', 1)
            elif cmp:
                self.print(self.shift+f'[ {dst2} ] is already copied.', 1)
            else:
                if self.force:
                    cmt_level = 3
                else:
                    cmt_level = 0
                self.print(self.shift + f'[ {dst2} ] is already existed.',
                           cmt_level)
        else:
            if islink:
                # broken link
                linkpath = dst.parent.joinpath(dst.readlink())
                os.unlink(dst)
                fg, end = get_color('error')
                self.print(f'{fg}{dst2} -> {self.home_cut(linkpath)} is a broken link. unlink.{end}', 0)
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
                self.print('', 0)
                self.diff(index)
                self.print('', 0)
                is_diff = True
            elif yn in ['n', 'no']:
                self.print('Do not copy '+src.name, 0)
                return False

    def show_files(self):
        fg, end = get_color('show_files')
        self.print(f'{fg}target files{end}', 2)

        for i in range(self.len):
            if self.py_version >= 3009 and self.src[i].is_relative_to(self.cwd):
                src = self.src[i].relative_to(self.cwd)
            else:
                src = self.src[i]
            self.print(f'{src} => {self.home_cut(self.dst[i])}', 2)
        self.print(f'{fg}=~=~=~=~=~=~=~=~=~={end}', 2)

    def home_cut(self, path: Path):
        home = Path.home()
        home2 = home.resolve()  # if home is symbolic link.
        if self.py_version < 3009:
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
            # if src.name in ignore_files:
            #     self.print(self.shift+f'[ {src.name} ] in ignore files. skip.',
            #                1)
            #     continue
            dst_dir = dst.parent
            if self.test:
                if not dst_dir.is_dir():
                    self.print(f'process check:: mkdir {dst_dir}', 0)
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
                                   0)
                        self.copy(src, dst)
                    elif islink:
                        continue
                    else:
                        if self.diff_check(i):
                            self.copy(src, dst)

    def clear(self, root: str, append_files: list[str] = []):
        clear_files = []
        dsts = self.dst + [Path(f) for f in append_files]
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
                    self.print(f'process check::unlink {f}', 0)
                else:
                    yn = input(f'unlink {f}? ([y]/n): ')
                    if yn != 'n':
                        os.unlink(f)
            else:
                if is_import_trash:
                    if self.test:
                        self.print(f'process check::move {f} to Trash', 0)
                    else:
                        yn = input(f'move {f} to Trash? ([y]/n): ')
                        if yn != 'n':
                            send2trash(f)
                else:
                    if self.test:
                        self.print(f'process check::remove {f}', 0)
                    else:
                        yn = input(f'remove {f}? ([y]/n): ')
                        if yn != 'n':
                            os.remove(f)


def print_warn(msg: str, **kwargs) -> None:
    fg, end = get_color('warning')
    print(f'{fg}{msg}{end}', **kwargs)

def print_path(path: str):
    fg, end = get_color('path')
    print(f'\n{fg}@ {path}{end}\n')


def get_opt_files(prefix: str) -> list[list[str]]:
    res = []
    for fy in (ROOT/'opt/bin').glob('*'):
        if fy.is_file() and os.access(fy, os.X_OK):
            dst = Path(prefix)/'bin'/fy.name
            res.append([f'{fy}', f'{dst}'])
    for fy in (ROOT/'opt/lib').glob('*'):
        if fy.is_file():
            dst = Path(prefix)/'lib'/fy.name
            res.append([f'{fy}', f'{dst}'])
    return res


def create_set(args: Args) -> None:
    local_conf = CONF_HOME/'meflib'
    if not local_conf.is_dir():
        try:
            local_conf.mkdir(parents=True)
            print(f'mkdir: {local_conf}')
        except Exception as e:
            print(f'failed to make conf dir: {local_conf}')
            print(f'error: {e}')
    res = ''

    # opt
    res += '[opt]\n'
    if args.opt_prefix is None:
        print('--opt_prefix is not set. Skip to create opt section.')
    else:
        if args.opt_dynamic:
            res += 'dyn = true\n'
            res += f'prefix = "{args.opt_prefix}"\n'
        else:
            res += 'files = [\n'
            for src, dst in get_opt_files(args.opt_prefix):
                res += f'    ["{src}", "{dst}"],\n'
            res += ']\n'
    res += '\n'

    # config
    res += '[config]\n'
    files = {
            'config/zsh/zshrc': '~/.zshrc',
            'config/zsh/zlogin': '~/.zlogin',
            'config/zsh/zsh': '~/.zsh',
            # 'config/tmp/zshrc.mine': '~/.zsh/zshrc.mine',
            'config/shell/posixShellRC': '~/.posixShellRC',
            'config/shell/psfuncs/get_zodiac_whgm.sh':
            local_conf/'get_zodiac_whgm.sh',
            'config/shell/psfuncs/today_percentage.sh':
            local_conf/'today_percentage.sh',
            'config/bash/bashrc': '~/.bashrc',
            'config/bash/bash': '~/.bash',
            # 'config/tmp/bashrc.mine': '~/.bash/bashrc.mine',
            'config/matplotlibrc':
            '~/.matplotlib/matplotlibrc' if uname == 'Darwin'
            else CONF_HOME/'matplotlib/matplotlibrc',
            'config/git/gitignore_global': '~/.gitignore_global',
            'config/screenrc': '~/.screenrc',
            # 'config/marp/marp_MeFtheme.css': '~/.marp/marp_MeFtheme.css',
            'config/git/tigrc':  '~/.tigrc',
            'config/fish/config.fish': CONF_HOME/'fish/config.fish',
            'config/fish/functions': CONF_HOME/'fish/functions',
            }
    res += 'files = [\n'
    for src, dst in files.items():
        src2 = ROOT/src
        dst2 = Path(dst).expanduser()
        if src2.is_file():
            res += f'    ["{src2}", "{dst2}"],\n'
        elif src2.is_dir():
            for src3 in src2.glob('**/*'):
                dst3 = dst2/f'{src3.relative_to(src2)}'
                res += f'    ["{src3}", "{dst3}"],\n'
    res += ']\n'
    res += 'clear = {'
    for root, fys in {CONF_HOME/'meflib': ['shows_config.json',
                                           SFILE.name,
                                           'setting_old.toml'],
                      Path('~/.zsh').expanduser(): ['zshrc.mine',
                                                    'zlogin.mine',
                                                    'enter.zsh'],
                      Path('~/.bash').expanduser(): ['bashrc.mine',
                                                     'git-prompt.sh'],
                      }.items():
        res += f'"{root}" = [\n'
        for fy in fys:
            res += f'    "{root/fy}",\n'
        res += '],'
    res = res[:-1]
    res += '}\n'

    res += '\n'

    # Vim
    res += '[vim]\n'
    if args.vim_prefix is None:
        print('--vim_prefix is not set. Skip to create vim section.')
    else:
        prefix = Path(args.vim_prefix)
        res += 'files = [\n'
        res += f'    ["{ROOT/"vim/vimrc"}", "{prefix/"init.vim"}"],\n'
        for host in [ROOT/'vim/rcdir',
                     ROOT/'vim/ftplugin',
                     ROOT/'vim/plug_conf',
                     ROOT/'vim/autoload',
                     ROOT/'vim/doc',
                     ROOT/'vim/after',
                     ]:
            for fy in host.glob('**/*'):
                if fy.is_dir():
                    continue
                dst = prefix/f'{fy.relative_to(ROOT/"vim")}'
                res += f'    ["{fy}", "{dst}"],\n'
        res += ']\n'
        res += 'clear = {'
        for root, fys in {prefix/'rcdir': ['vimrc_mine.pre',
                                           'vimrc_mine.post'],
                          prefix/'plug_conf': [],
                          }.items():
            res += f'"{root}" = [\n'
            for fy in fys:
                res += f'    "{root/fy}",\n'
            res += '],'
        res = res[:-1]
        res += '}\n'
        res += 'vimlink = [\n'
        for src, dst in [[prefix/'init.vim', Path('~/.vimrc').expanduser()],
                         [prefix, Path('~/.vim').expanduser()],
                         ]:
            res += f'    ["{src}", "{dst}"],\n'
        res += ']\n'

    res += '\n'

    # color
    colors = {
            "message": 11,
            "warning": 136,
            "diff_plus": 12,
            "diff_minus": 1,
            "error": 1,
            "show_files": 2,
            "path": 10,
            }
    res += '[color]\n'
    for cname, cidx in colors.items():
        res += f'{cname} = {cidx}\n'
    res += '\n'

    # print(res)
    with open(SFILE, 'w') as f:
        f.write(res)


def get_files(setup_path: str | None,
              args_type: TypeList, prefix: str | None):
    if setup_path is None:
        return None

    fpath = Path(setup_path).expanduser()
    if not fpath.exists():
        print(f"setup_file {fpath} doesn't find. use default settings.")
        return None

    with open(fpath, 'r') as f:
        set_dict = json.load(f)
    if args_type in set_dict:
        res_files = {}
        for src in set_dict[args_type]:
            dest = set_dict[args_type][src]
            if '$PREFIX' in dest:
                if prefix is None:
                    print(f'prefix is None: skip {src}')
                    continue
                dest = dest.replace('$PREFIX', prefix)
            res_files[src] = dest
        return res_files
    else:
        print(f'{args_type} is not in {fpath}. use default settings.')
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

    global COLORS
    with open(setfile, 'r') as f:
        conf = json.load(f)
        if 'color' in conf:
            color_conf = conf['color']
            for key in COLORS:
                if key in color_conf:
                    if type(color_conf[key]) is int and \
                       0 <= color_conf[key] < 256:
                        COLORS[key] = color_conf[key]
                    elif color_conf[key] is None:
                        COLORS[key] = None


def get_color(colname: str) -> tuple[str, str]:
    if colname not in COLORS:
        return '', ''
    if COLORS[colname] is None:
        return '', ''
    return FG256(COLORS[colname]), END


def set_ignore_files(args: Args) -> None:
    if args.setup_file is None:
        return
    setfile = Path(args.setup_file)
    if not setfile.is_file():
        return

    global ignore_files
    with open(setfile, 'r') as f:
        conf = json.load(f)
        if 'ignore files' in conf:
            ignore_files = conf['ignore files']


def create_update(args: Args, bindir: str):
    if not Path(bindir).is_dir():
        print(f'{bindir} is not found. update_setup is not created')
        return

    pyopt = ''
    pyopt += ' --type ' + ' '.join(args.type)
    if args.link:
        pyopt += ' --link'
    if args.force:
        pyopt += ' --force'
    if args.verbose > 0:
        pyopt += ' -'+'v'*args.verbose
    if args.clear:
        pyopt += ' --clear'
    with open(ROOT/'opt/samples/update_setup_sample.py', 'r') as f:
        update_setup = f.read().format(ROOT.absolute(),
                                       ROOT.absolute(),
                                       ROOT.absolute(),
                                       pyopt).replace('\\', '\\\\')

    update_setup_file = Path(bindir)/'update_setup'
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
            print(f'create update_setup in {bindir}')
            print('---- diff -----')
            for line in us_diff:
                print(line.replace('\n', ''))
            print('---------------')
        else:
            print(f'creating update_setup file in {bindir} ...')
            print('---- diff -----')
            for line in us_diff:
                print(line.replace('\n', ''))
            print('---------------')
            with open(update_setup_file, 'w') as f:
                f.write(update_setup)
            update_setup_file.chmod(0o744)
            if uname == 'Windows':
                print('create setup.bat')
                with open(ROOT/'opt/samples/setup_sample.bat', 'r') as f:
                    update_bat = f.read().format(pyopt).replace('\\', '\\\\')
                with open(ROOT/'setup.bat', 'w') as f:
                    f.write(update_bat)
            print('done')


def _main_opt(args: Args):
    if args.prefix is None:
        return
    print_path(args.opt_src)
    spec_files = {'pdf2jpg': ['Darwin']}

    files = get_files(args.setup_file, 'opt', args.prefix)
    if files is None:
        files = {}
        for bfy in args.bin_src.glob('*'):
            if os.access(bfy, os.X_OK):
                fname = bfy.name
                if fname in spec_files:
                    if uname in spec_files[fname]:
                        files[bfy] = args.bin_dst/fname
                else:
                    files[bfy] = args.bin_dst/fname

        for lfy in args.lib_src.glob('*'):
            fname = lfy.name
            if fname == '__pycache__':
                continue
            if not fname.endswith('pyc'):
                files[lfy] = args.lib_dst/fname
        pv_path = chk_cmd('aftviewer', return_path=True)
        if pv_path is not None:
            pv_lib = args.conf_home/'aftviewer'
            pv_ex_d = Path('samples/pyviewer_examples')
            pv_exs = {'fits_healpy.py': 'additional_types/fits_healpy.py',
                      'plotly.py': 'additional_ivs/plotly.py',
                      'xml.py': 'additional_types/xml.py',
                      }
            for pe in pv_exs:
                mkdir(str((pv_lib/pv_exs[pe]).parent))
                files[pv_ex_d/pe] = str(pv_lib/pv_exs[pe])

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   verbose=args.verbose)
    for fy in sorted(files.keys()):
        cc.stack(args.opt_src.joinpath(fy), files[fy])
    cc.show_files()
    cc.exec()
    # opt は関係ないbin, libもあるのでclearは呼ばない


def _main_conf(args: Args):
    print_path(args.conf_src)

    files_mac = {
                'zsh/zshrc': '~/.zshrc',
                'zsh/zlogin': '~/.zlogin',
                'zsh/zsh': '~/.zsh',
                'tmp/zshrc.mine': '~/.zsh/zshrc.mine',
                'shell/posixShellRC': '~/.posixShellRC',
                'shell/psfuncs/get_zodiac_whgm.sh':
                args.local_conf/'get_zodiac_whgm.sh',
                'shell/psfuncs/today_percentage.sh':
                args.local_conf/'today_percentage.sh',
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
                  'shell/psfuncs/get_zodiac_whgm.sh':
                  args.local_conf/'get_zodiac_whgm.sh',
                  'shell/psfuncs/today_percentage.sh':
                  args.local_conf/'today_percentage.sh',
                  'bash/bashrc': '~/.bashrc',
                  'bash/bash': '~/.bash',
                  'tmp/bashrc.mine': '~/.bash/bashrc.mine',
                  'matplotlibrc':
                  Path(args.conf_home)/'matplotlib/matplotlibrc',
                  'git/gitignore_global': '~/.gitignore_global',
                  'screenrc': '~/.screenrc',
                  'git/tigrc':  '~/.tigrc',
                  'fish/config.fish': Path(args.conf_home)/'fish/config.fish',
                  'fish/functions': Path(args.conf_home)/'fish/functions',
                }

    files_win: dict[str, str] = {}

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
        if args.test:
            print('test:: download git-prompt for bash')
        else:
            print('download git-prompt for bash')
            try:
                bashdir = Path('~/.bash').expanduser()
                mkdir(bashdir)
                urlreq.urlretrieve('https://raw.githubusercontent.com/git/git/'
                                   'master/contrib/completion/git-prompt.sh',
                                   bashdir/'git-prompt.sh')
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
                            f.write(f'export PATH=\\\n"{args.bin_dst}":\\\n$PATH')
                            f.write('\n')
                        if args.lib_dst is not None:
                            f.write(f'export PYTHONPATH=\\\n"{args.lib_dst}"{psep}\\\n$PYTHONPATH')
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
                   verbose=args.verbose)
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


def _main_vim(args: Args):
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
        if args.test:
            print('test:: download vimPlug')
        else:
            print('\ndownload vimPlug')
            mkdir(args.al_dst)
            urlreq.urlretrieve('https://raw.githubusercontent.com/junegunn/'
                               'vim-plug/master/plug.vim',
                               args.al_dst/'plug.vim')

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   verbose=args.verbose)
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


def main_opt(setting: dict[str, Any], args: Args) -> None:
    if 'opt' not in setting:
        print(f'opt is not found in {SFILE}. skip opt.')
        return
    conf = setting['opt']
    print_path('opt')
    if 'dyn' in conf and conf['dyn']:
        if 'prefix' not in conf:
            fg, end = get_color('warning')
            print(f'{fg}dynamic is set but prefix is not set.{end}')
            return
        files = get_opt_files(conf['prefix'])
    elif 'files' in conf:
        files = conf['files']
    else:
        print_warn('"files" not found in opt.')
        return
    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   verbose=args.verbose)
    for src, dst in files:
        cc.stack(src, dst)
    cc.show_files()
    cc.exec()
    # opt は関係ないbin, libもあるのでclearは呼ばない


def main_conf(setting: dict[str, Any], args: Args) -> None:
    if 'config' not in setting:
        print(f'config is not found in {SFILE}. skip conf.')
        return
    conf = setting['config']
    print_path('config')
    if 'files' not in conf:
        print_warn('"files" not found in conf.')
        return
    files = conf['files']

    if args.download:
        if args.test:
            print('test:: download git-prompt for bash')
        else:
            print('download git-prompt for bash')
            try:
                bashdir = Path('~/.bash').expanduser()
                mkdir(bashdir)
                urlreq.urlretrieve('https://raw.githubusercontent.com/git/git/'
                                   'master/contrib/completion/git-prompt.sh',
                                   bashdir/'git-prompt.sh')
            except Exception as e:
                print('failed to download git-prompt')
                print(f'error: {e}')

    # create ~.mine files
    if not args.test:
        for shell in 'bash zsh'.split():
            if f'config/{shell}/{shell}rc' in [f[0] for f in files]:
                mine_file = Path(f'~/.{shell}rc.mine').expanduser()
                if mine_file.is_file():
                    print(f'{shell}rc.mine already exists.')
                else:
                    with open(mine_file, 'w') as f:
                        f.write(f'''
## PC dependent {shell}rc
#
''')
                        print(f'made {shell}rc.mine file.')
            # mine_src = 'tmp/{}rc.mine'.format(shell)
            # if mine_src in files:
            #     if not Path(files[mine_src]).expanduser().is_file():
            #         mine_src_path = args.conf_src/mine_src
            #         mkdir(str(mine_src_path.parent))
            #         with open(mine_src_path, 'w') as f:
            #             f.write('## PC dependent {}rc\n'.format(shell))
            #             f.write('#\n')
            #             f.write('\n')
            #             if args.bin_dst is not None:
            #                 f.write(f'export PATH=\\\n"{args.bin_dst}":\\\n$PATH')
            #                 f.write('\n')
            #             if args.lib_dst is not None:
            #                 f.write(f'export PYTHONPATH=\\\n"{args.lib_dst}"{psep}\\\n$PYTHONPATH')
            #                 f.write('\n')
            #             f.write('\n')
            #         print('made {}rc.mine'.format(shell))
            #     else:
            #         print('{}rc.mine is already exists'.format(shell))
            #         files.pop(mine_src)

        # create tigrc.mine
        if 'config/git/tigrc' in [f[0] for f in files]:
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
                   verbose=args.verbose)
    for src, dst in files:
        cc.stack(src, dst)
    cc.show_files()
    cc.exec()
    if args.clear and 'clear' in conf:
        for cl in conf['clear']:
            cc.clear(cl, conf['clear'][cl])
        # cc.clear(args.local_conf,
        #          [args.local_conf/'shows_config.json'])
        # zshdir = Path('~/.zsh').expanduser()
        # bashdir = Path('~/.bash').expanduser()
        # cc.clear(str(zshdir), [zshdir/'zshrc.mine',
        #                        zshdir/'zlogin.mine', zshdir/'enter.zsh'])
        # cc.clear(str(bashdir), [bashdir/'bashrc.mine',
        #                         bashdir/'git-prompt.sh'])


def main_vim(setting: dict[str, Any], args: Args) -> None:
    if 'vim' not in setting:
        print(f'vim is not found in {SFILE}. skip vim.')
        return
    conf = setting['vim']
    print_path('vim')
    if 'files' not in conf:
        print_warn('"files" not found in conf.')
        return
    files = conf['files']

    if args.download:
        if args.test:
            print('test:: download vimPlug')
        else:
            print('\ndownload vimPlug')
            mkdir(args.al_dst)
            urlreq.urlretrieve('https://raw.githubusercontent.com/junegunn/'
                               'vim-plug/master/plug.vim',
                               args.al_dst/'plug.vim')

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   verbose=args.verbose)
    for src, dst in files:
        cc.stack(src, dst)
    cc.show_files()
    cc.exec()
    if args.clear and 'clear' in conf:
        for cl in conf['clear']:
            cc.clear(cl, conf['clear'][cl])
    # if args.clear:
    #     cc.clear(str(args.vim_conf/'rcdir'),
    #              [args.rc_dst/'vimrc_mine.post', args.rc_dst/'vimrc_mine.pre'])
    #     cc.clear(str(args.vim_conf/'plug_conf'))

    if 'vimlink' in conf:
        for src, dst in conf['vimlink']:
            if not Path(dst).exists():
                if not args.test:
                    print(f'link {src} -> {dst}.')
                    try:
                        os.symlink(src, dst)
                    except Exception as e:
                        print(f'failed to link {src}.')
                        print(f'error: {e}')
    # if not uname == 'Windows':
    #     src = args.vimrc
    #     dst = Path('~/.vimrc').expanduser()
    #     if src.is_file() and not dst.is_file():
    #         if not args.test:
    #             print("link {} -> {}".format(src, dst))
    #             try:
    #                 os.symlink(src, dst)
    #             except Exception as e:
    #                 print('failed to link vimrc.')
    #                 print('error: {}'.format(e))

    #     src = args.vim_conf
    #     dst = Path('~/.vim').expanduser()
    #     if src.is_dir() and not dst.is_dir():
    #         if not args.test:
    #             print("link {} -> {}".format(src, dst))
    #             try:
    #                 os.symlink(src, dst)
    #             except Exception as e:
    #                 print('failed to link vim dir.')
    #                 print('error: {}'.format(e))


def main():
    parser = argparse.ArgumentParser()
    # parser.add_argument('--prefix', help='install directory',
    #                     default=Path('~/workspace/opt').expanduser())
    parser.add_argument('--create_settings',
                        help=f'create {SFILE.name} and return.',
                        action='store_true')
    parser.add_argument('--opt_prefix',
                        help=f'**option for {SFILE.name}.**'
                        ' install directory of files in "opt".',
                        default=None)
    parser.add_argument('--vim_prefix', help=f'**option for {SFILE.name}.**'
                        ' Vim configuration directory.',
                        default=None)
    parser.add_argument('--opt_dynamic', help=f'**option for {SFILE.name}.**'
                        ' If set, set copying files in "opt" dynamically.',
                        action='store_true')
    parser.add_argument('--download', help='download some files (from git)',
                        action='store_true')
    parser.add_argument('--link', help="link files instead of copy",
                        action='store_true')
    parser.add_argument('--test', help="don't copy, just show command",
                        action='store_true')
    parser.add_argument('-f', '--force',
                        help='Do not prompt for confirmation before '
                        'overwriting the destination path',
                        action='store_true')
    parser.add_argument('-t', '--type', nargs='*',
                        help="set the type of copy files.",
                        choices='all opt config vim'.split(), default=['all'])
    # parser.add_argument('-s', '--setup_file',
    #                     help='specify the copy files by json format '
    #                     'setting file. please see '
    #                     '"opt/samples/setup_file_template.json"'
    #                     ' as an example.')
    parser.add_argument('-c', '--clear', action='store_true',
                        help='clear unused files')
    parser.add_argument('-v', '--verbose', action='count', default=0,
                        help='show verbose messages')
    args = parser.parse_args()

    if not SFILE.is_file():
        print(f'{SFILE} is not found. create it and return.')
        create_set(args)
        return
    elif args.create_settings:
        shutil.copy(SFILE, SFILE.parent/'setting_old.toml')
        create_set(args)
        return

    with open(SFILE, 'rb') as f:
        settings = tomllib.load(f)
    if 'color' in settings:
        COLORS.update(settings['color'])

    if 'all' in args.type:
        main_opt(settings, args)
        main_conf(settings, args)
        main_vim(settings, args)
    else:
        for t in args.type:
            if t == 'opt':
                main_opt(settings, args)
            elif t == 'config':
                main_conf(settings, args)
            elif t == 'vim':
                main_vim(settings, args)
    us_path = chk_cmd('update_setup', return_path=True)
    if us_path is None:
        bindir = os.path.expanduser(input('install path of "update_setup": '))
    else:
        bindir = str(Path(us_path).parent)
    create_update(args, bindir)

    return
    # if not Path(args.prefix).is_dir():
    #     print("install path {} does not exit".format(args.prefix))
    #     args.prefix = None

    # fpath = Path(__file__).resolve().parent
    # args.fpath = fpath
    # os.chdir(fpath)
    # set_path(args)
    # set_color(args)
    # set_ignore_files(args)

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
