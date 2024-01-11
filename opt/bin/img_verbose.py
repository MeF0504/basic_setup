#! /usr/bin/env python3
import os
import sys
from datetime import datetime
import argparse

import numpy as np
from PIL import Image
import plotly.graph_objects as go
from plotly.subplots import make_subplots

from pymeflib import plot2


def get_tag(exif_info, tag_name):
    # https://www.vieas.com/exif23.html
    # https://www.cipa.jp/std/documents/j/DC-008-2012_J.pdf
    exif_tag = {
            'ImageDescription': 0x010e,
            'Make': 0x010f,
            'Model': 0x0110,
            'Orientation': 0x0112,
            'XResolution': 0x011a,
            'YResolution': 0x011b,
            'ResolutionUnit': 0x0128,
            'DateTime': 0x0132,
            'YCbCrPositioning': 0x0213,
            'Exif IFD Pointer': 0x8769,
            }

    if tag_name not in exif_tag:
        if args.verbose:
            print(f'incorrect tag name: {tag_name}', file=sys.stderr)
        return None
    field = exif_tag[tag_name]
    if field not in exif_info:
        return None
    else:
        return exif_info[field]


def main(args):
    img_file = args.image_file
    if os.path.isdir(img_file):
        print(f'{img_file} is a directory.', file=sys.stderr)
        return
    if not os.path.isfile(img_file):
        print(f'file {img_file} does not exist.', file=sys.stderr)
        return
    img_name = os.path.basename(img_file)
    img_data = Image.open(img_file)
    img_exif = img_data.getexif()
    if args.verbose:
        print('exif information;')
        print('index: values')
        for key, val in img_exif.items():
            print(f' {key:4x}: {val}')
    if 'RGB' not in img_data.mode:
        img_data = img_data.convert('RGBA')
    img_data = np.asarray(img_data)
    h, w, c = img_data.shape
    date = os.stat(img_file).st_mtime
    date = datetime.fromtimestamp(date).strftime('%Y-%m-%d %H:%M')

    R_data = img_data[:, :, 0].flatten()
    G_data = img_data[:, :, 1].flatten()
    B_data = img_data[:, :, 2].flatten()
    RGB2YCbCr = [[0.299, 0.587, 0.114],
                 [-0.169, -0.331, 0.500],
                 [0.500, -0.419, 0.081]]
    Y_data, Cb_data, Cr_data = np.dot(RGB2YCbCr, [R_data, G_data, B_data])
    Cb_data = np.where(Cb_data < 0, 0, Cb_data)
    Cr_data = np.where(Cr_data < 0, 0, Cr_data)
    Y_data = np.where(Y_data > 255, 255, Y_data)
    Cb_data = np.where(Cb_data > 255, 255, Cb_data)
    Cr_data = np.where(Cr_data > 255, 255, Cr_data)

    if args.fft:
        f_R = np.fft.fft2(img_data[:, :, 0])
        f_R_shift = np.fft.fftshift(f_R)
        power_R = 20*np.log(np.absolute(f_R_shift))
        f_G = np.fft.fft2(img_data[:, :, 1])
        f_G_shift = np.fft.fftshift(f_G)
        power_G = 20*np.log(np.absolute(f_G_shift))
        f_B = np.fft.fft2(img_data[:, :, 2])
        f_B_shift = np.fft.fftshift(f_B)
        power_B = 20*np.log(np.absolute(f_B_shift))
        power = np.zeros_like(img_data)
        power[:, :, 0] = power_R
        power[:, :, 1] = power_G
        power[:, :, 2] = power_B

    # fig = go.Figure().set_subplots(rows=2, cols=2)
    fig = make_subplots(rows=2, cols=2, vertical_spacing=0.1,
                        specs=[[{"type": "image"}, {"type": "table"}],
                               [{"type": "image"}, {}]],
                        subplot_titles=("raw image", "information",
                                        "2D FFT", "histogram")
                        )

    # add_trace? append_trace?
    fig.append_trace(go.Image(z=img_data), row=1, col=1)

    xrslv = get_tag(img_exif, 'XResolution')
    yrslv = get_tag(img_exif, 'YResolution')
    data_table = [
            ['name', 'data size', 'file created date',
             'title', 'maker', 'model', 'resolutions', 'exif date',
             ],
            [img_name, f'{w}x{h}', date,
             get_tag(img_exif, 'ImageDescription'),
             get_tag(img_exif, 'Make'),
             get_tag(img_exif, 'Model'),
             f'{xrslv}x{yrslv}',
             get_tag(img_exif, 'DateTime'),
             ]]
    fig.append_trace(go.Table(
        cells=dict(
            values=data_table,
            line_color="darkslategray",
            align=["center", "center"],
            font=dict(color="darkslategray", size=12),
            )),
                     row=1, col=2)

    if args.fft:
        fig.append_trace(go.Image(z=power), row=2, col=1)

    plot2.hist_np(fig, R_data,
                  xmin=0, xmax=255, xbins=256,
                  row=2, col=2,
                  name='Red', opacity=0.5, marker=dict(color='Red'),
                  )
    plot2.hist_np(fig, G_data,
                  xmin=0, xmax=255, xbins=256,
                  row=2, col=2,
                  name='Green', opacity=0.5, marker=dict(color='Green'),
                  )
    plot2.hist_np(fig, B_data,
                  xmin=0, xmax=255, xbins=256,
                  row=2, col=2,
                  name='Blue', opacity=0.5, marker=dict(color='Blue'),
                  )
    plot2.hist_np(fig, Y_data,
                  xmin=0, xmax=255, xbins=256,
                  row=2, col=2,
                  name='Y', opacity=0.5, marker=dict(color='Grey'),
                  visible='legendonly',
                  )
    plot2.hist_np(fig, Cb_data,
                  xmin=0, xmax=255, xbins=256,
                  row=2, col=2,
                  name='Cb', opacity=0.5, marker=dict(color='Cyan'),
                  visible='legendonly',
                  )
    plot2.hist_np(fig, Cr_data,
                  xmin=0, xmax=255, xbins=256,
                  row=2, col=2,
                  name='Cr', opacity=0.5, marker=dict(color='Magenta'),
                  visible='legendonly',
                  )
    fig.update_layout(barmode='overlay',  # stack, group, overlay, relative
                      xaxis3=dict(title='RGB/YCbCr values'),
                      yaxis3=dict(title='counts'))

    fig.show()


if __name__ == '__main__':
    parser = argparse.ArgumentParser('show information of a image file.')
    parser.add_argument('image_file', help='image file.')
    parser.add_argument('--fft', help='do 2-dimensional FFT.',
                        action='store_true')
    parser.add_argument('--verbose', '-v', help='show verbose',
                        action='store_true')
    args = parser.parse_args()
    main(args)
