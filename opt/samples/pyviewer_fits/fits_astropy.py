from pathlib import Path

from astropy.io import fits
# astropy requires NumPy!
import numpy as np

from . import args_chk, show_image_ndarray, help_template


def local_color_map(data_i, max_val, min_val=0):
    scale = 255*(data_i-min_val)/(max_val-min_val)
    return [scale, scale, scale]


def show_help():
    helpmsg = help_template('fits_astropy', 'show the image of fits file.' +
                            ' args.key specifies an index of HDUList, and' +
                            ' if no key is specified, show the HDU info.' +
                            ' Note that the values of each pixel are' +
                            ' displayed in log scale.',
                            sup_iv=True, sup_k=True)
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
    max_val = np.log10(np.max(data))
    data2 = np.array([[local_color_map(np.log10(x), max_val)
                       if x > 0 else [0, 0, 0]
                       for x in tmp]
                      for tmp in data], dtype=np.uint8)
    show_image_ndarray(data2, fname, args)
