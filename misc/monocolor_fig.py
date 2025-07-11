#! /usr/bin/env python3

from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
from pymeflib import plot as mefplot


def main():
    width = 640
    height = 480
    outdir = Path(__file__).parent.parent/'tmp/colfigs'
    if not outdir.is_dir():
        outdir.mkdir(parents=True)

    cols = {'White': (100, 100, 100), 'Red': (80, 0, 0),
            'Green': (0, 80, 0), 'Blue': (0, 0, 80), 'Black': (0, 0, 0)}
    for name, col in cols.items():
        img = np.ones((height, width, 3))
        for i in range(3):
            img[:, :, i] *= col[i]/100.0
        fig1 = mefplot.get_fig_w_pixels(width, height, dpi=100)
        ax11 = fig1.add_axes((0, 0, 1, 1))
        ax11.imshow(img)
        ax11.xaxis.set_visible(False)
        ax11.yaxis.set_visible(False)
        ax11.spines['top'].set_visible(False)
        ax11.spines['bottom'].set_visible(False)
        ax11.spines['right'].set_visible(False)
        ax11.spines['left'].set_visible(False)
        fig1.savefig(outdir/f'mono_{name}.png')
    plt.close()


if __name__ == '__main__':
    main()
