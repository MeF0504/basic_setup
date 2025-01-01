#! /usr/bin/env python3

import argparse
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt


def main(args):
    outdir = Path(args.outdir)
    x = np.arange(0, args.num_wave, 0.01)
    y = np.sin(x*2*np.pi)
    fig1 = plt.figure(figsize=(8, 4))
    ax11 = fig1.add_subplot(1, 1, 1)
    ax11.plot(x, y, c='k', lw=args.linewidth)
    ax11.grid(False)
    ax11.axis('off')
    fig1.savefig(outdir/'curve.png', transparent=True)
    plt.show()


if __name__ == '__main__':
    parser = argparse.ArgumentParser('make curve fig')
    parser.add_argument('--outdir', '-o', help='output directory',
                        default='.')
    parser.add_argument('--linewidth', '-lw', help='line width',
                        type=int, default=4)
    parser.add_argument('--num_wave', '-n', help='number of waves',
                        type=int, default=5)
    args = parser.parse_args()
    main(args)
