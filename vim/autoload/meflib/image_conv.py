#! /usr/bin/env python3

import os.path as op

import vim
try:
    from PIL import Image
except ImportError:
    print('PIL (Pillow) is not installed.')

    def convert_image(*args, **kwargs):
        return None
    exit()


def convert_image(path: str, height: str | None):
    # なんかvim.eval で渡された整数はstrになっちゃう？
    name = op.splitext(op.basename(path))[0]
    with Image.open(path) as img:
        w, h = img.size
        if height is not None and h != int(height):
            width = int(int(height)*w/h)
            im2 = img.resize((width, int(height)))
        else:
            im2 = img
        w, h = im2.size
        data = list(im2.get_flattened_data())
        data2 = sum([list(d) for d in data], [])  # flatten
        data_str = ', '.join([f'{d:d}' for d in data2])
        vim.command(f'let meflib#image#data = [{data_str}]')
        vim.command(f'let meflib#image#h = {h}')
        vim.command(f'let meflib#image#w = {w}')
        # vim.command('echomsg "meflib#image#data"')
        # vim.command('echomsg meflib#image#w')
