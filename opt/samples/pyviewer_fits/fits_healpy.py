from pathlib import Path

import matplotlib.pyplot as plt
import healpy as hp

from . import args_chk, help_template


def show_help():
    helpmsg = help_template('fits_healpy', 'show the image of fits file' +
                            ' using HealPix.' +
                            ' args.key specifies field.',
                            sup_k=True)
    print(helpmsg)


def main(fpath, args):
    fname = Path(fpath).name
    if args_chk(args, 'key'):
        if len(args.key) == 0:
            print('please use "-t fits_astropy -k" to see HDU info.')
            return
        else:
            field = int(args.key[0])
    else:
        field = 0
    heal_map = hp.read_map(fpath, field=field)
    hp.mollview(heal_map, title=fname)
    plt.show()
