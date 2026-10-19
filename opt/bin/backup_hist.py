#! /usr/bin/env python3

import os
import shutil
import glob
from datetime import datetime, timedelta

try:
    from send2trash import send2trash
except ImportError:
    send2trash = None


def main(verbose):
    histfile = os.environ.get('HISTFILE')
    if histfile is None:
        if verbose:
            print('HISTFILE is not set.')
        return
    if not os.path.isfile(histfile):
        if verbose:
            print('HISTFILE is not found.')
        return

    tdy = datetime.today()
    hist_back_pre = glob.glob(histfile+'.*')
    if len(hist_back_pre) == 0:
        histtime_pre = datetime(1970, 1, 1)
    else:
        hist_back_pre = sorted(hist_back_pre)
        histtime_pre = datetime.fromtimestamp(os.path.getctime(hist_back_pre[-1]))
    if tdy-histtime_pre > timedelta(days=14):
        hist_back = histfile+tdy.strftime('.%Y%m%d')
        shutil.copy(histfile, hist_back)
        print(f'copy {hist_back}')
        for fy in hist_back_pre:
            if send2trash is not None:
                send2trash(fy)
                if verbose:
                    print(f'trash {fy}')
            else:
                os.remove(fy)
                if verbose:
                    print(f'remove {fy}')


if __name__ == '__main__':
    main(True)
