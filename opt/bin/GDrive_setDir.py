#! /usr/bin/env python3

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
    config_file = Path('~/.config/meflib/user.toml').expanduser()
    if not config_file.is_file():
        print('setting file is not found.')
        return

    with open(config_file, 'rb') as f:
        settings = tomllib.load(f)
    Gdir = Path(settings['Gdir'])
    if not Gdir.is_dir():
        print('Google Drive dir is not found.')
        return

    dname = sys.argv[1]
    if len(dname) == 0:
        print('name is not set.')
        return

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
