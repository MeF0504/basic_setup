
import os
import sys
import json

BG = {
        'k': '\033[40m',
        'w': '\033[47m',
        'r': '\033[41m',
        'g': '\033[42m',
        'b': '\033[44m',
        'm': '\033[45m',
        'c': '\033[46m',
        'y': '\033[43m'}
FG = {
        'k': '\033[30m',
        'w': '\033[37m',
        'r': '\033[31m',
        'g': '\033[32m',
        'b': '\033[34m',
        'm': '\033[35m',
        'c': '\033[36m',
        'y': '\033[33m'}
END = '\033[0m'
col_list = None


def BG256(n):
    if (0 <= n < 256):
        return '\033[48;5;%dm' % n
    else:
        return ''


def FG256(n):
    if (0 <= n < 256):
        return '\033[38;5;%dm' % n
    else:
        return ''


def make_bitmap(filename, rgb, bmp_type='Windows', verbose=False):
    if rgb.shape[-1] == 4:
        rgb = rgb[:, :, [0, 1, 2]]

    height, width, cols = rgb.shape
    if verbose:
        print('{}x{}x{}'.format(height, width, cols))
        print('bitmap type: {}'.format(bmp_type))

    # make color table (it doesn't need in 24bmp format.)
    # q_bit = 256
    color_table = []
    # for r in range(q_bit):
    #     for g in range(q_bit):
    #         for b in range(q_bit):
    #             color_table += [int(b), int(g), int(r), int(0)]
    # if verbose:
    #     print('color table: ({}); {}...'.format(len(color_table), color_table[:10]))
    len_cols = len(color_table)
    num_cols = len(color_table) >> 2

    # make pixel data
    img_data = []
    for i in range(height):
        line_data = []
        for j in range(width):
            r, g, b = rgb[height-i-1, j]     # starts from left botom
            line_data += [b, g, r]
        # line length should be a multiple of 4 bytes (long).
        padding = 4*(int((len(line_data)-1)/4)+1)-len(line_data)
        for k in range(padding):
            line_data.append(0)
        img_data += line_data
    if verbose:
        print_st = '{}, '.format(img_data[0])
        print_end = '{}'.format(img_data[-1])
        for i in range(1, 6):
            print_st += '{}, '.format(img_data[i])
            print_end = '{}, '.format(img_data[-i-1]) + print_end
        print('pixel data: ({}); [{} ... {}]'.format(len(img_data), print_st, print_end))
    len_data = len(img_data)

    if bmp_type == 'Windows':
        offset = 0x0e+0x28+len_cols
    elif bmp_type == 'OS/2':
        offset = 0x0e+0x0c+len_cols
    else:
        print('incorrect file format: {}.'.format(bmp_type), file=sys.stderr)
        return None
    file_size = offset+len_data

    # make binary data
    # FILE_HEADER
    b = bytearray([0x42, 0x4d])                 # signature 'BM'
    b.extend(file_size.to_bytes(4, 'little'))   # file size
    b.extend((0).to_bytes(2, 'little'))         # reserved
    b.extend((0).to_bytes(2, 'little'))         # reserved
    b.extend(offset.to_bytes(4, 'little'))      # offset

    # INFO_HEADER
    if bmp_type == 'Windows':
        b.extend((0x28).to_bytes(4, 'little'))      # size of header
        b.extend(width.to_bytes(4, 'little'))       # width [dot]
        b.extend(height.to_bytes(4, 'little'))      # height [dot]
        b.extend((1).to_bytes(2, 'little'))         # number of planes
        b.extend((8*3).to_bytes(2, 'little'))       # byte/1pixel
        b.extend((0).to_bytes(4, 'little'))         # type of compression (0=BI_RGB, no compression)
        b.extend(len_data.to_bytes(4, 'little'))     # size of image
        b.extend((0).to_bytes(4, 'little'))         # horizontal resolution
        b.extend((0).to_bytes(4, 'little'))         # vertical resolution
        b.extend(num_cols.to_bytes(4, 'little'))    # number of colors (not used for 24bmp)
        b.extend((0).to_bytes(4, 'little'))         # import colors (0=all)
    elif bmp_type == 'OS/2':
        b.extend((0x0c).to_bytes(4, 'little'))      # size of header
        b.extend(width.to_bytes(2, 'little'))       # width [dot]
        b.extend(height.to_bytes(2, 'little'))      # height [dot]
        b.extend((1).to_bytes(2, 'little'))         # number of planes
        b.extend((8*3).to_bytes(2, 'little'))       # byte/1pixel

    # COLOR_TABLES
    b.extend(color_table)

    # DATA
    b.extend(img_data)

    with open(filename, 'wb') as f:
        f.write(b)

    if verbose:
        filesize = os.path.getsize(filename)
        prefix = ''
        if filesize > 1024**3:
            filesize /= 1024**3
            prefix = 'G'
        elif filesize > 1024**2:
            filesize /= 1024**2
            prefix = 'M'
        elif filesize > 1024:
            filesize /= 1024
            prefix = 'k'
        print('size of made file: {:.1f} {}B'.format(filesize, prefix))


def convert_color_name(color_name, color_type, verbose=False):
    if color_type not in ['256', 'full']:
        if verbose:
            print('incorrect color type ({}).'.format(color_type))
            print('selectable type: "256" or "full". return None.')
        return None

    global col_list
    if col_list is None:
        color_set = os.path.dirname(__file__)+'/color_set.json'
        if os.path.isfile(color_set):
            with open(color_set, 'r') as f:
                col_list = json.load(f)
        else:
            print('color set file is not found.')
            col_list = {}

        try:
            import matplotlib.colors as mcolors
        except ImportError:
            if verbose:
                print('matplotlib is not imported.')
        else:
            named_colors = mcolors.get_named_colors_mapping()
            col_list.update(named_colors)

        for i in range(101):
            if 'gray{:d}'.format(i) in col_list:
                continue
            gray_level = int(255*i/100+0.5)
            col_list['gray{:d}'.format(i)] = {'256': None, 'full': '#{:02x}{:02x}{:02x}'.format(gray_level, gray_level, gray_level)}
            col_list['grey{:d}'.format(i)] = {'256': None, 'full': '#{:02x}{:02x}{:02x}'.format(gray_level, gray_level, gray_level)}

    if color_name not in col_list:
        if verbose:
            print('no match color name {} found. return None.'.format(color_name))
        return None
    else:
        col = col_list[color_name]
        if type(col) == dict:
            return col[color_type]
        elif type(col) == str:
            if color_type == 'full':
                return col_list[color_name]
            elif color_type == '256':
                r = int(col[1:3], 16)
                g = int(col[3:5], 16)
                b = int(col[5:7], 16)
                return convert_fullcolor_to_256(r, g, b)
        else:
            r, g, b = col
            if color_type == 'full':
                return '#{:02x}{:02x}{:02x}'.format(int(255*r), int(255*g), int(255*b))
            elif color_type == '256':
                r = int(r*255)
                g = int(g*255)
                b = int(b*255)
                return convert_fullcolor_to_256(r, g, b)


def convert_256_to_fullcolor(color_index):
    if color_index < 16:
        color_list = [
                'Black',
                'Maroon',
                'Green',
                'Olive',
                'Navy',
                'Purple',
                'Teal',
                'Silver',
                'Grey',
                'Red',
                'Lime',
                'Yellow',
                'Blue',
                'Fuchsia',
                'Aqua',
                'White',
        ]
        return color_list[color_index]
    elif color_index < 232:
        r_index = int((color_index-16)/36)
        g_index = int((color_index-16-36*r_index)/6)
        b_index = int(color_index-16-36*r_index-6*g_index)
        if r_index != 0:
            r_index = 55+40*r_index
        if g_index != 0:
            g_index = 55+40*g_index
        if b_index != 0:
            b_index = 55+40*b_index
        return '#{:02x}{:02x}{:02x}'.format(r_index, g_index, b_index)
    elif color_index < 256:
        gray_level = 8+10*(color_index-232)
        return '#{:02x}{:02x}{:02x}'.format(gray_level, gray_level, gray_level)


def convert_fullcolor_to_256(r, g, b):
    r_index = int((r-55)/40+0.5)
    if r_index < 0:
        r_index = 0
    g_index = int((g-55)/40+0.5)
    if g_index < 0:
        g_index = 0
    b_index = int((b-55)/40+0.5)
    if b_index < 0:
        b_index = 0

    return 36*r_index+6*g_index+b_index+16


def main_test(num, deci):
    print('system colors')
    for i in range(8):
        if num:
            if deci:
                if i % 2 == 0:    # even
                    tmp_st = '{}{:03d}{}|'.format(FG['w'], i, END)
                else:           # odd
                    tmp_st = '{}{:03d}{}|'.format(FG['k'], i, END)
            else:
                if i % 2 == 0:    # even
                    tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
                else:           # odd
                    tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print()
    for i in range(8, 16):
        if num:
            if deci:
                if i % 2 == 0:    # even
                    tmp_st = '{}{:03d}{}|'.format(FG['w'], i, END)
                else:           # odd
                    tmp_st = '{}{:03d}{}|'.format(FG['k'], i, END)
            else:
                if i % 2 == 0:    # even
                    tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
                else:           # odd
                    tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print('\n')

    print('6x6x6 color blocks')
    for g in range(6):
        for r in range(6):
            for b in range(6):
                i = 36*r+6*g+b+16
                if num:
                    if deci:
                        if i % 2 == 0:    # even
                            tmp_st = '{}{:03d}{}'.format(FG['w'], i, END)
                        else:           # odd
                            tmp_st = '{}{:03d}{}'.format(FG['k'], i, END)
                    else:
                        if i % 2 == 0:    # even
                            tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
                        else:           # odd
                            tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
                else:
                    tmp_st = '  '
                print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
            print(' ', end='')
        print()
    print()

    print('gray scales')
    st = 6*6*6+16
    for i in range(st, 256):
        if num:
            if deci:
                tmp_st = '{}{:03d}{}|'.format(FG256(255+st-i), i, END)
            else:
                tmp_st = '{}{:02x}{}'.format(FG256(255+st-i), i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print('\n')


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', help='show number', action='store_true')
    parser.add_argument('-d', help='show in decimal number format', action='store_true')
    args = parser.parse_args()

    main_test(args.n, args.d)
