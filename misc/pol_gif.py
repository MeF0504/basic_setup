#! /usr/bin/env python3

import os
import subprocess
from pathlib import Path
import tempfile

import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm


def plot_data(phase: float, N: int, save_dir: str, footer: str):
    sdir = Path(save_dir)
    for i in tqdm(range(100*N)):
        t = np.arange(0, 2, 0.01)
        x = np.sin(2*np.pi*(t+i*0.01))
        y = np.sin(2*np.pi*(t+i*0.01)+phase)
        fig1 = plt.figure(figsize=(5, 5))
        ax11 = fig1.add_subplot(1, 1, 1, projection='3d')
        ax11.plot(-np.ones_like(t), t, x, 'b', lw=3)
        ax11.plot(y, t, -np.ones_like(t), 'r', lw=3)
        ax11.plot([-1, y[0]], [0, 0], [x[0], x[0]], 'b--', lw=1)
        ax11.plot([y[0], y[0]], [0, 0], [-1, x[0]], 'r--', lw=1)
        ax11.plot(y, np.zeros_like(t), x, 'g-', lw=1)
        ax11.plot([y[0]], [0], [x[0]], 'go', lw=3)
        ax11.set_xlabel('')
        ax11.set_ylabel('')
        ax11.set_zlabel('')
        plt.subplots_adjust(left=0.0, right=1., bottom=0.0, top=1.)
        ax11.set_xticklabels([])
        ax11.set_yticklabels([])
        ax11.set_zticklabels([])
        ax11.set_box_aspect([1, 3, 1])
        ax11.grid(False)
        plt.savefig(sdir/f'pol{footer}_{i:03d}.png', transparent=True)
        plt.close()

    outfile = Path(__file__).parent.parent/f'tmp/out_{footer}.gif'
    os.chdir(sdir)
    subprocess.run(['ffmpeg',
                    '-i', f'pol{footer}_%03d.png',
                    '-vf', 'palettegen', 'palette.png'])
    subprocess.run(['ffmpeg',
                    '-f', 'image2',
                    '-r', '24',
                    '-i', f'pol{footer}_%03d.png',
                    '-i', 'palette.png',
                    '-filter_complex', 'paletteuse',
                    outfile])
    print(f'save to {outfile}')


def main():
    # 3d polarization
    tmpdir = tempfile.TemporaryDirectory()

    plot_data(0, 1, tmpdir.name, 'lin')
    plot_data(np.pi/2, 1, tmpdir.name, 'cir')
    tmpdir.cleanup()


if __name__ == '__main__':
    main()
