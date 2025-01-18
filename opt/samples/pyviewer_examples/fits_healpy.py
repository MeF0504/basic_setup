from pathlib import Path

import numpy as np
import healpy as hp
import matplotlib.pyplot as plt

from aftviewer import args_chk, help_template, get_config, add_args_key


def add_args(parser):
    add_args_key(parser,
                 help='Specify the index of field/HDU. To see the details,'
                 ' please run "aftviewer FILE -t fits -k".')
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
    helpmsg = help_template('fits_healpy',
                            'Show the image of fits file using HealPix.',
                            add_args)
    print(helpmsg)


def main(fpath, args):
    fname = Path(fpath).name
    if args_chk(args, 'key'):
        if len(args.key) == 0:
            print('please use "-t fits_astropy -k" to see HDU info.')
            return
        else:
            fields = [int(k) for k in args.key]
    else:
        fields = [0]

    if hasattr(args, 'projection') and args.projection is not None:
        projection = args.projection
    elif get_config('projection') is not None:
        projection = get_config('projection')
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
    elif get_config('norm') is not None:
        norm = get_config('norm')
    else:
        norm = 'None'
    if norm == 'None':
        norm = None

    if hasattr(args, 'coord') and args.coord is not None:
        coord = args.coord
    elif get_config('coord') is not None:
        coord = get_config('coord')
    else:
        coord = []
    if len(coord) == 0:
        coord = None

    if hasattr(args, 'cl'):
        cl = args.cl
    else:
        cl = False

    heal_maps = hp.read_map(fpath, field=fields)
    if len(fields) == 1:
        heal_maps = [heal_maps]
    for i, field in enumerate(fields):
        if norm == 'log':
            # is this correct?
            heal_map_plot = np.abs(heal_maps[i])
        else:
            heal_map_plot = heal_maps[i]
        viewer(heal_map_plot, title=f'{fname} ({field})',
               coord=coord, norm=norm, fig=1, sub=(len(fields), 1, i+1))
    if cl:
        fig2 = plt.figure(figsize=(10, 5))
        for i, field in enumerate(fields):
            ax21 = fig2.add_subplot(len(fields), 1, i+1)
            # LMAX = 1024
            cl = hp.anafast(heal_maps[i])  # , lmax=LMAX)
            ell = np.arange(len(cl))
            ax21.plot(ell, ell*(ell+1)/(2*np.pi) * cl)
            ax21.set_xlabel(r'$\ell$')
            ax21.set_ylabel(r'$\ell(\ell+1)/2\pi\ \ C_{\ell}$')
            ax21.set_yscale('log')
    plt.show()
