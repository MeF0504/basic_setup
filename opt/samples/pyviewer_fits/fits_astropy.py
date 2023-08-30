from pathlib import Path

from astropy.io import fits
# astropy requires NumPy!
import numpy as np

from . import args_chk, show_image_ndarray, help_template


def show_help():
    helpmsg = help_template('fits_astropy', 'show the image of fits file.' +
                            ' args.key specifies an index of HDUList, and' +
                            ' if no key is specified, show the HDU info.' +
                            ' Note that the values of each pixel are' +
                            ' displayed in log scale.',
                            sup_iv=True, sup_k=True,
                            add_args='add_args_fits')
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
        data = hdul[idx].data

    if len(data.shape) != 2:
        print('This function assumes 2D image. this is {}.'.format(data.shape))
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
