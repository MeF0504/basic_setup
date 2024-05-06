from pathlib import Path

from astropy.io import fits
# astropy requires NumPy!
import numpy as np

from aftviewer import args_chk, show_image_ndarray, help_template, \
    add_args_imageviewer, add_args_key


def add_args(parser):
    add_args_imageviewer(parser)
    add_args_key(parser)
    parser.add_argument('--log_scale', help='scale color in log.',
                        action='store_true')


def show_help():
    helpmsg = help_template('fits_astropy', 'show the image of fits file.' +
                            ' -k/--key specifies an index of HDU' +
                            ' (Header Data Unit) list, and' +
                            ' if no key is specified, show the HDU info.' +
                            ' Note that the values of each pixel are' +
                            ' subtracted by min value.',
                            add_args)
    print(helpmsg)


def main(fpath, args):
    fname = Path(fpath).name
    if args_chk(args, 'key'):
        if len(args.key) == 0:
            with fits.open(fpath) as hdul:
                hdul.info()
            return
        else:
            idx = int(args.key[0])
    else:
        idx = 0

    with fits.open(fpath) as hdul:
        if idx >= len(hdul):
            print(f'key index {idx} > num of HDU (max: {len(hdul)-1})')
            return
        data = hdul[idx].data

    if not hasattr(data, 'shape'):
        print(f'data type may not correct: {type(data)}')
        return
    if len(data.shape) != 2:
        print(f'This function assumes 2D image. this is {data.shape}.')
        return
    data -= np.nanmin(data)
    data = np.where(data == data, data, 0)
    if hasattr(args, 'log_scale') and args.log_scale:
        data = np.log10(data+1)
    max_val = np.max(data)
    data2 = np.zeros((data.shape[0], data.shape[1], 3))
    data2[:, :, 0] = 255.0*data/max_val
    data2[:, :, 1] = 255.0*data/max_val
    data2[:, :, 2] = 255.0*data/max_val
    data2 = data2.astype(np.uint8)
    # 上下反転
    data2 = data2[::-1]
    show_image_ndarray(data2, fname, args)
