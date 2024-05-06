import xml.etree.ElementTree as ET
import argparse
from pathlib import Path, PurePath
from typing import Tuple, List
from functools import partial
from logging import getLogger

from aftviewer import GLOBAL_CONF, Args, ReturnMessage as RM, \
    add_args_specification, args_chk, get_col, cprint, print_key, \
    interactive_view, interactive_cui
from pymeflib.tree2 import show_tree


logger = getLogger(GLOBAL_CONF.logname)


def get_detail(el: ET.Element):
    txt = ''
    txt += f'{el.tag} ['
    items = [f'{key}={item}' for key, item in el.attrib.items()]
    txt += ', '.join(items)
    txt += ']'
    if len(el) == 0:
        return f'{txt}: {el.text}'
    else:
        info = '\n'.join([f'  {i}:{child.tag}' for i, child in enumerate(el)])
        return f'{txt}\n{info}'


def get_key_name(root: ET.Element, path: str):
    tmp = root
    ret_path = []
    try:
        for p in PurePath(path).parts:
            ret_path.append(tmp.tag)
            idx = int(str(p).split(':')[0])
            tmp = tmp[idx]
    except Exception:
        return ''
    return '/'.join(ret_path)


def get_contents(root: ET.Element, path: PurePath) \
        -> Tuple[List[str], List[str]]:
    tmp = root
    dirs = []
    files = []
    for p in path.parts:
        idx = int(str(p).split(':')[0])
        tmp = tmp[idx]
    for i, child in enumerate(tmp):
        if len(child) == 0:
            files.append(f'{i}:{child.tag}')
        else:
            dirs.append(f'{i}:{child.tag}')

    return dirs, files


def show_func(root: ET.Element, cpath: str, **kwargs) -> RM:
    tmp = root
    path = PurePath(cpath)
    for p in path.parts:
        try:
            idx = int(str(p).split(':')[0])
        except ValueError:
            return RM(f'incorrect index specification ({p}).', True)
        try:
            tmp = tmp[idx]
        except IndexError:
            return RM(f'index {idx} out of range (< {len(tmp)})', True)
    return RM(get_detail(tmp), False)


def add_args(parser: argparse.ArgumentParser):
    add_args_specification(parser, verbose=False, key=True,
                           interactive=True, cui=True)


def show_help():
    pass


def main(fpath: Path, args: Args):
    fname = fpath.name
    tree = ET.parse(fpath)
    root = tree.getroot()
    sf = partial(show_func, root)
    gc = partial(get_contents, root)

    if args_chk(args, 'key'):
        fg, bg = get_col('msg_error')
        if args.key:
            for k in args.key:
                print_key(get_key_name(root, k))
                info = show_func(root, k)
                if not info.error:
                    print(info.message)
                    print()
                else:
                    cprint(info.message, fg=fg, bg=bg)
        else:
            print(get_detail(root))
    elif args_chk(args, 'interactive'):
        interactive_view(fname, gc, sf)
    elif args_chk(args, 'cui'):
        interactive_cui(fname, gc, sf)
    else:
        show_tree(fname, gc, logger=logger)
