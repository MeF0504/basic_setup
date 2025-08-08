#! /usr/bin/env python3

import os
import sys
from pathlib import Path
_py_version = sys.version_info.major*1000 + sys.version_info.minor
if _py_version < 3006:
    print('Version >= 3.6 required')
    sys.exit()
if _py_version < 3011:
    print('use tomli')
    import tomli as tomllib
else:
    import tomllib


def main():
    if 'XDG_CONFIG_HOME' in os.environ:
        xdg_dir = Path(os.environ['XDG_CONFIG_HOME'])
    else:
        xdg_dir = Path('~/.config').expanduser()

    config_file = xdg_dir/'meflib/user.toml'
    if not config_file.is_file():
        print('setting file is not found.')
        return

    with open(config_file, 'rb') as f:
        settings = tomllib.load(f)
    Gdir = Path(settings['GDrive_setDir']['Gdir'])
    if not Gdir.is_dir():
        print('Google Drive dir is not found.')
        return

    if '-h' in sys.argv or '--help' in sys.argv:
        print('Usage: GDrive_setDir.py <dirname>')
        print('Create directories in Google Drive.')
        print('dirname: name of the directory to create')
        print(f'Gdir: {Gdir}')
        return
    if len(sys.argv) < 2:
        print('name is not set.')
        return
    dname = sys.argv[1]

    dirs = ['WallPaper',
            'WallPaper/SmartphonePaper',
            'Images',
            'Movies',
            '資料',
            ]
    for d in dirs:
        print(Gdir/dname/d)
    yn = input('Create above dirs? (y/[n]): ')
    if yn == 'y':
        for d in dirs:
            dst = Gdir/dname/d
            if not dst.is_dir():
                dst.mkdir(parents=True)
                print(f'made {dst}')


if __name__ == '__main__':
    main()
