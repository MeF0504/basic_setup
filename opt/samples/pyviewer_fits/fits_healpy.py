from pathlib import Path

import numpy as np
import healpy as hp
import matplotlib.pyplot as plt

from . import args_chk, help_template, get_config, add_args_key


def add_args(parser):
    add_args_key(parser)
    parser.add_argument('--projection', help='specify the projection',
                        choices=['mollweide', 'gnomonic',
                                 'cartesian', 'orthographic'],
                        )
    parser.add_argument('--norm', help='specify color normalization',
                        choices=['hist', 'log', 'None'])
    parser.add_argument('--cl', help='show cl', action='store_true')
    parser.add_argument('--coord', help='Either one of' +
                        ' ‘G’, ‘E’ or ‘C’' +
                        ' to describe the coordinate system of the map, or' +
                        ' a sequence of 2 of these to rotate the map from' +
                        ' the first to the second coordinate system.',
                        nargs='*')


def show_help():
    helpmsg = help_template('fits_healpy', 'show the image of fits file' +
                            ' using HealPix.' +
                            ' args.key specifies field.',
                            add_args)
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

    if hasattr(args, 'projection') and args.projection is not None:
        projection = args.projection
    elif get_config('fits_healpy', 'projection') is not None:
        projection = get_config('fits_healpy', 'projection')
    else:
        projection = 'mollweide'

    if projection == 'mollweide':
        viewer = hp.mollview
    elif projection == 'gnomonic':
        viewer = hp.gnomview
    elif projection == 'cartesian':
        viewer = hp.cartview
    elif projection == 'orthographic':
        viewer = hp.orthview
    else:
        print(f'incorrect projection: {projection}')
        return

    if hasattr(args, 'norm') and args.norm is not None:
        norm = args.norm
    elif get_config('fits_healpy', 'norm') is not None:
        norm = get_config('fits_healpy', 'norm')
    else:
        norm = 'None'
    if norm == 'None':
        norm = None

    if hasattr(args, 'coord') and args.coord is not None:
        coord = args.coord
    elif get_config('fits_healpy', 'coord') is not None:
        coord = get_config('fits_healpy', 'coord')
    else:
        coord = []
    if len(coord) == 0:
        coord = None

    if hasattr(args, 'cl'):
        cl = args.cl
    else:
        cl = False

    heal_map = hp.read_map(fpath, field=field)
    viewer(heal_map, title=fname, coord=coord, norm=norm)
    if cl:
        LMAX = 1024
        cl = hp.anafast(heal_map, lmax=LMAX)
        ell = np.arange(len(cl))
        fig2 = plt.figure(figsize=(10, 5))
        ax21 = fig2.add_subplot(111)
        ax21.plot(ell, ell*(ell+1)/(2*np.pi) * cl)
        ax21.set_xlabel(r'$\ell$')
        ax21.set_ylabel(r'$\frac{\ell(\ell+1)}{2\pi} C_{\ell}$')
        ax21.set_yscale('log')
    plt.show()
