#! /usr/bin/env python3

import os
import shutil
import argparse
from argparse import ArgumentDefaultsHelpFormatter
from pathlib import Path

try:
    from send2trash import send2trash
except ImportError:
    import_send2trash = False
else:
    import_send2trash = True


def main(args):
    root = Path(args.root_dir)
    if args.target == 'list':
        for d in root.glob('*'):
            if not d.is_dir():
                continue
            if d.name.startswith('_'):
                continue
            print(d.name)
        return

    install_dir = root/args.target
    old_dir = root/f'_{args.target}'
    if install_dir.is_dir():
        if old_dir.is_dir():
            if import_send2trash:
                send2trash(old_dir)
                print(f'move {old_dir} to Trash.')
            else:
                shutil.rmtree(old_dir)
                print(f'remove {old_dir}')
        print(f'move {install_dir} to {old_dir}')
        shutil.move(install_dir, old_dir)
    if install_dir.exists():
        print(f'failed to remove current {install_dir}')
        return
    print(f'make {install_dir}')
    install_dir.mkdir(parents=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='create a directory to install a software and move old directory.',
                                     formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument('target', help='target name of directory, or "list" shows current directories in the `root_dir`.')
    parser.add_argument('--root_dir', help='root directory',
                        default=os.path.expanduser('~/workspace/softwares'))
    args = parser.parse_args()
    main(args)
