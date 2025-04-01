from __future__ import annotations

import os
import sys
import argparse
import shutil
import filecmp
import difflib
from datetime import datetime
import platform
import urllib.request as urlreq
from pathlib import Path
from typing import Literal, Any
from dataclasses import dataclass
import subprocess
import json
import pprint
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
SFILE = CONF_HOME/'meflib/setting.json'
IGFILE = CONF_HOME/'meflib/ignorelist'
ROOT = Path(__file__).resolve().parent.relative_to(os.getcwd())

COLORS = {}

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

    opt_prefix: str | None
    vim_prefix: str | None
    download: bool
    link: bool
    test: bool
    force: bool
    type: list[TypeList]
    clear: bool
    verbose: int


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

    def stack(self, src_str: str, dst_str: str):
        src = Path(src_str).expanduser().absolute()
        dst = Path(dst_str).expanduser()
        if src.is_file():
            assert dst.is_file() or not dst.exists()
            self.src.append(src)
            self.dst.append(dst)
            self.len += 1
        elif src.is_dir():
            self.print_warn(f"{src} is a directory.", 0)
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
        src_dt = datetime.fromtimestamp(src.stat().st_mtime)
        dst_dt = datetime.fromtimestamp(dst.stat().st_mtime)
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


def print_title(title: str):
    fg, end = get_color('path')
    tsize = shutil.get_terminal_size()
    enum = int((tsize.columns-len(title)-4)/2)
    print(f'\n{fg}{"="*enum} {title} {"="*enum}{end}\n')


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
        res += f'prefix = "{args.opt_prefix}"\n'
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
        res += f'prefix = "{args.vim_prefix}"\n'
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
    res = res.replace('\\ ', ' ')
    res = res.replace('\\', '\\\\')
    return res


def get_color(colname: str) -> tuple[str, str]:
    if colname not in COLORS:
        return '', ''
    if COLORS[colname] is None:
        return '', ''
    if COLORS[colname] < 0:  # none/null is not supported in toml
        return '', ''
    return FG256(COLORS[colname]), END


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


def create_settings(args: Args):
    dic = {}
    if 'all' in args.type or 'opt' in args.type:
        dic['opt'] = {}
        opt_def = os.path.expanduser('~/workspace/opt')
        opt_dir = input('install directory of files in "opt"\n'
                        f'(empty => {opt_def}): ')
        if len(opt_dir) == 0:
            opt_dir = opt_def
        dic['opt']['dir'] = opt_dir
    if 'all' in args.type or 'vim' in args.type:
        dic['vim'] = {}
        if chk_cmd('nvim'):
            nvim = True
        else:
            nvim = False
        dic['vim']['nvim'] = nvim
        if nvim:
            vim_def = os.path.expanduser('~/.config/nvim')
        else:
            vim_def = os.path.expanduser('~/.vim')
        vim_dir = input('Vim configuration directory\n'
                        f'(empty => {vim_def}): ')
        if len(vim_dir) == 0:
            vim_dir = vim_def
        dic['vim']['dir'] = vim_dir
        if nvim:
            yn = input('link to vimrc and ~/.vim? ([y]/n): ')
            if yn != 'n':
                dic['vim']['link'] = True
            else:
                dic['vim']['link'] = False
    if 'all' in args.type or 'config' in args.type:
        dic['config'] = {}
        if chk_cmd('zsh'):
            dic['config']['zsh'] = True
        else:
            dic['config']['zsh'] = False
        if chk_cmd('fish'):
            dic['config']['fish'] = True
        else:
            dic['config']['fish'] = False
    jset = json.dumps(dic)
    jset = jset.replace('{', '{\n    ')
    jset = jset.replace('},', '},\n    ')
    with open(SFILE, 'w') as f:
        f.write(jset)


def get_ignore_list() -> list[str]:
    if not IGFILE.is_file():
        return []
    with open(IGFILE, 'r') as f:
        lines = f.readlines()
    lines = [line.replace('\n', '') for line in lines]
    return lines


def get_opt_list(setting: dict[str, Any]) -> list[list[str]]:
    if 'opt' not in setting:
        print(f'opt is not found in {SFILE}. skip opt.')
        return []
    res = []
    ignore_list = get_ignore_list()
    for fy in (ROOT/'opt/bin').glob('*'):
        if fy.name in ignore_list:
            continue
        if fy.is_file() and os.access(fy, os.X_OK):
            dst = Path(setting['opt']['dir'])/'bin'/fy.name
            res.append([f'{fy}', f'{dst}'])
    for fy in (ROOT/'opt/lib').glob('*'):
        if fy.is_file():
            dst = Path(setting['opt']['dir'])/'lib'/fy.name
            res.append([f'{fy}', f'{dst}'])
    return res


def main_opt(setting: dict[str, Any], args: Args) -> None:
    # if 'opt' not in setting:
    #     print(f'opt is not found in {SFILE}. skip opt.')
    #     return
    # conf = setting['opt']
    print_title('opt')
    # if 'files' not in conf:
    #     print_warn('"files" not found in opt.')
    #     return
    # files = conf['files']
    files = get_opt_list(setting)
    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   verbose=args.verbose)
    for src, dst in files:
        cc.stack(src, dst)
    cc.show_files()
    cc.exec()
    # opt は関係ないbin, libもあるのでclearは呼ばない


def get_conf_list(setting: dict[str, Any]) -> list[list[str]]:
    if 'config' not in setting:
        print(f'config is not found in {SFILE}. skip config.')
        return []
    res = []
    ignore_list = get_ignore_list()
    home = Path.home()
    # unix shell
    r = ROOT/'config/shell'
    for fy in r.glob('**/*'):
        if fy.name in ignore_list:
            continue
        elif fy.name == 'posixShellRC':
            res.append([f'{fy}', f'{home/".posixShellRC"}'])
        else:
            if fy.is_file():
                dst = CONF_HOME/'meflib'/fy.name
                res.append([f'{fy}', f'{dst}'])
    # bash
    r = ROOT/'config/bash'
    for fy in r.glob('**/*'):
        if fy.name in ignore_list:
            continue
        elif fy.name == 'plain_rc':
            continue
        elif fy.name == 'bashrc':
            res.append([f'{fy}', f'{home/".bashrc"}'])
        else:
            if fy.is_file():
                dst = (home/'.bash')/fy.name
                res.append([f'{fy}', f'{dst}'])
    # zsh
    if setting['config']['zsh']:
        r = ROOT/'config/zsh'
        for fy in r.glob('**/*'):
            if fy.name in ignore_list:
                continue
            elif fy.name == 'zshrc':
                res.append([f'{fy}', f'{home/".zshrc"}'])
            elif fy.name == 'zlogin':
                res.append([f'{fy}', f'{home/".zlogin"}'])
            else:
                if fy.is_file():
                    dst = (home/'.zsh')/fy.name
                    res.append([f'{fy}', f'{dst}'])
    # fish
    if setting['config']['fish']:
        r = ROOT/'config/fish'
        for fy in r.glob('**/*'):
            if fy.name in ignore_list:
                continue
            elif fy.name == 'config.fish':
                res.append([f'{fy}', f'{home/".config/fish/config.fish"}'])
            else:
                if fy.is_file():
                    dst = (home/'.config/fish')/fy.relative_to(r)
                    res.append([f'{fy}', f'{dst}'])
    # git
    res.append([f'{ROOT/"config/git/gitignore_global"}',
               f'{home/".gitignore_global"}'])
    res.append([f'{ROOT/"config/git/tigrc"}',
               f'{home/".tigrc"}'])
    # other
    res.append([f'{ROOT/"config/screenrc"}',
               f'{home/".screenrc"}'])
    if uname == 'Darwin':
        res.append([f'{ROOT/"config/matplotlibrc"}',
                   f'{home/".matplotlib/matplotlibrc"}'])
    else:
        res.append([f'{ROOT/"config/matplotlibrc"}',
                   f'{CONF_HOME/"matplotlib/matplotlibrc"}'])
    return res


def main_conf(setting: dict[str, Any], args: Args) -> None:
    # if 'config' not in setting:
    #     print(f'config is not found in {SFILE}. skip conf.')
    #     return
    # conf = setting['config']
    print_title('config')
    # if 'files' not in conf:
    #     print_warn('"files" not found in conf.')
    #     return
    # files = conf['files']

    files = get_conf_list(setting)
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
                mine_file = Path(f'~/.{shell}/{shell}rc.mine').expanduser()
                if mine_file.is_file():
                    print(f'{shell}rc.mine already exists.')
                else:
                    with open(mine_file, 'w') as f:
                        f.write(f'''
## PC dependent {shell}rc
#
''')
                        print(f'made {shell}rc.mine file.')

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
    if args.clear:
        home = Path.home()
        cc.clear(f'{CONF_HOME}/"meflib"',
                 [f'{CONF_HOME/"meflib/setting.json"}',
                  ])
        cc.clear(f'{home/".bash"}',
                 [f'{home/".bash/bashrc.mine"}',
                  f'{home/".bash/git-prompt.sh"}',
                  ])
        if not setting['config']['zsh']:
            cc.clear(f'{home/".zsh"}',
                     [f'{home/".zsh/zshrc.mine"}',
                      f'{home/".zsh/zlogin.mine"}',
                      f'{home/".zsh/enter.zsh"}',
                      ])
    # if args.clear and 'clear' in conf:
    #     for cl in conf['clear']:
    #         cc.clear(cl, conf['clear'][cl])


def get_vim_list(setting: dict[str, Any]) -> list[list[str]]:
    if 'vim' not in setting:
        print(f'vim is not found in {SFILE}. skip vim.')
        return []
    res = []
    home = Path.home()
    ignore_list = get_ignore_list()
    if setting['vim']['nvim']:
        res.append([f'{ROOT/"vim/vimrc"}',
                    f'{CONF_HOME/"nvim/init.vim"}'])
    else:
        res.append([f'{ROOT/"vim/vimrc"}',
                    f'{home/".vimrc"}'])
    vimdst = Path(setting['vim']['dir'])
    for fy in (ROOT/'vim').glob('*/**/*'):
        if fy.name in ignore_list:
            continue
        if fy.name == 'doc.py':
            continue
        if fy.is_file():
            dst = vimdst/fy.relative_to(ROOT/"vim")
            res.append([f'{fy}', f'{dst}'])
    return res


def main_vim(setting: dict[str, Any], args: Args) -> None:
    # if 'vim' not in setting:
    #     print(f'vim is not found in {SFILE}. skip vim.')
    #     return
    # conf = setting['vim']
    print_title('vim')
    # if 'files' not in conf:
    #     print_warn('"files" not found in conf.')
    #     return
    # files = conf['files']

    files = get_vim_list(setting)
    if args.download:
        if args.test:
            print('test:: download vimPlug')
        else:
            print('\ndownload vimPlug')
            vimal = os.path.expanduser(input("install dir of vimPlug: "))
            mkdir(vimal)
            urlreq.urlretrieve('https://raw.githubusercontent.com/junegunn/'
                               'vim-plug/master/plug.vim',
                               vimal/'plug.vim')

    cc = CopyClass(link=args.link, force=args.force, test=args.test,
                   verbose=args.verbose)
    for src, dst in files:
        cc.stack(src, dst)
    cc.show_files()
    cc.exec()
    if args.clear:
        vimdst = Path(setting['vim']['dir'])
        cc.clear(f'{vimdst/"rcdir"}',
                 [f'{vimdst/"rcdir/vimrc_mine.pre"}',
                  f'{vimdst/"rcdir/vimrc_mine.post"}',
                  ])
        cc.clear(f'{vimdst/"plug_conf"}', [])
    # if args.clear and 'clear' in conf:
    #     for cl in conf['clear']:
    #         cc.clear(cl, conf['clear'][cl])

    home = Path.home()
    if setting['vim']['link']:
        if args.test:
            print('test:: link ~/.vim and ~/.vimrc')
        else:
            print('link ~/.vim and ~/.vimrc')
            try:
                if not (home/'.vim').exists():
                    os.symlink(setting['vim']['dir'], home/'.vim')
                if not (home/'.vimrc').exists():
                    os.symlink(setting['vim']['dir']/'init.vim', home/'.vimrc')
            except Exception as e:
                print('failed to link ~/.vimrc')
                print(f'error: {e}')
    # if 'vimlink' in conf:
    #     for src, dst in conf['vimlink']:
    #         if not Path(dst).exists():
    #             if not args.test:
    #                 print(f'link {src} -> {dst}.')
    #                 try:
    #                     os.symlink(src, dst)
    #                 except Exception as e:
    #                     print(f'failed to link {src}.')
    #                     print(f'error: {e}')


def main():
    parser = argparse.ArgumentParser()
    # parser.add_argument('--create_settings',
    #                     help=f'create {SFILE.name} and return.',
    #                     action='store_true')
    # parser.add_argument('--opt_prefix',
    #                     help=f'**option for {SFILE.name}.**'
    #                     ' install directory of files in "opt".',
    #                     default=None)
    # parser.add_argument('--vim_prefix', help=f'**option for {SFILE.name}.**'
    #                     ' Vim configuration directory.',
    #                     default=None)
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
    parser.add_argument('-c', '--clear', action='store_true',
                        help='clear unused files')
    parser.add_argument('-v', '--verbose', action='count', default=0,
                        help='show verbose messages')
    args = parser.parse_args()

    # if not SFILE.is_file():
    #     print(f'{SFILE} is not found. create it and return.')
    #     res = create_set(args)
    #     with open(SFILE, 'w') as f:
    #         f.write(res)
    #     print(f'{SFILE} is created. Please check it.')
    #     return
    # elif args.create_settings:
    #     shutil.copy(SFILE, SFILE.parent/'setting_old.toml')
    #     res = create_set(args)
    #     with open(SFILE, 'w') as f:
    #         f.write(res)
    #     print(f'{SFILE} is created. Please check it.')
    #     return

    # with open(SFILE, 'rb') as f:
    #     settings = tomllib.load(f)
    # if 'color' in settings:
    #     COLORS.update(settings['color'])

    # if args.verbose >= 1:
    #     if 'opt' in settings and 'prefix' in settings['opt']:
    #         args.opt_prefix = settings['opt']['prefix']
    #     if 'vim' in settings and 'prefix' in settings['vim']:
    #         args.vim_prefix = settings['vim']['prefix']
    #     with open(SFILE, 'r') as f:
    #         pri = [s.rstrip() for s in f.readlines()]
    #     new = create_set(args).split('\n')
    #     dlines = difflib.unified_diff(pri, new, n=1,
    #                                   fromfile=str(SFILE),
    #                                   tofile='new',
    #                                   )
    #     print_title('setting updates?')
    #     for line in dlines:
    #         line = line.replace('\n', '')
    #         if line[0] == '+':
    #             col, end = get_color('diff_plus')
    #         elif line[0] == '-':
    #             col, end = get_color('diff_minus')
    #         else:
    #             col = ''
    #             end = ''
    #         print(f'{col}{line}{end}')
    if not SFILE.is_file():
        create_settings(args)
    with open(SFILE, 'r') as f:
        setting = json.load(f)
    # pprint.pprint(get_opt_list(setting))
    # print('\n')
    # pprint.pprint(get_conf_list(setting))
    # print('\n')
    # pprint.pprint(get_vim_list(setting))
    # print('\n')
    # return

    if 'all' in args.type:
        main_opt(setting, args)
        main_conf(setting, args)
        main_vim(setting, args)
    else:
        for t in args.type:
            if t == 'opt':
                main_opt(setting, args)
            elif t == 'config':
                main_conf(setting, args)
            elif t == 'vim':
                main_vim(setting, args)
    us_path = chk_cmd('update_setup', return_path=True)
    if us_path is not None:
        bindir = str(Path(us_path).parent)
    elif 'opt' in setting and 'dir' in setting['opt']:
        bindir = os.path.join(setting['opt']['dir'], 'bin')
    else:
        bindir = os.path.expanduser(input('install path of "update_setup": '))
    print_title('create update')
    create_update(args, bindir)


if __name__ == "__main__":
    main()
