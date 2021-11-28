
import re
import sys

from local_lib_color import convert_color_name, convert_fullcolor_to_256

import_numpy = False

class XPMLoader():
    def __init__(self, xpm_file):
        res = ''
        com_lines = False

        with open(xpm_file) as f:
            for line in f:
                line = line.replace("\t", " ")
                tmpline = ''
                for i,char in enumerate(line):
                    if char == '/':
                        if line[i+1] == '/':
                            # comment line; //
                            if not com_lines:
                                break
                        elif line[i+1] == '*':
                            # comment lines; /*
                            com_lines = True
                        elif line[i-1] == '*':
                            # already passed; */
                            continue
                        else:
                            if not com_lines:
                                tmpline += char
                    elif char == '*':
                        if line[i+1] == '/':
                            # end of comment lines; */
                            com_lines = False
                        else:
                            if not com_lines:
                                tmpline += char
                    else:
                        if not com_lines:
                            tmpline += char
                tmpline = tmpline.replace("\n", "")
                res += tmpline

        res = res[res.find('{')+1:res.rfind('}')]
        res = eval("["+res+']')
        info_list = [int(s) for s in re.split(' +', res[0]) if s != '']
        if len(info_list) == 4:
            width, height, colors, char_per_pixel = info_list
        elif len(info_list) == 6:
            width, height, colors, char_per_pixel, x_hot, y_hot = info_list
        else:
            print('{}: fail to load xpm file (color settings).'.format(xpm_file), file=sys.stderr)
            return
        info = { \
                'width'  : width, \
                'height' : height, \
                'colors' : colors, \
                'char_per_pixel' : char_per_pixel \
                }
        # print(width, height, colors, char_per_pixel)

        tmp_color_settings = res[1:colors+1]
        color_settings = {}
        for cs in tmp_color_settings:
            char = cs[:char_per_pixel]
            cs_tmp = re.split(' +', cs)
            color_settings[char] = {}
            for i,c in enumerate(cs_tmp[1:]):
                if c == 'c':
                    color_settings[char]['color'] = cs_tmp[i+1+1].lower()
                elif c == 's':
                    color_settings[char]['str'] = cs_tmp[i+1+1]
                elif c == 'm':
                    color_settings[char]['mono'] = cs_tmp[i+1+1]
                elif c == 'g':
                    color_settings[char]['gray'] = cs_tmp[i+1+1]
        # print(color_settings)

        body = res[colors+1:]
        # print(body[:3])
        assert height == len(body)
        assert width*char_per_pixel == len(body[0])

        self.file_name = xpm_file
        self.info = info
        self.color_settings = color_settings
        self.body = body

    def get_color_settings_full(self):
        color_setting = self.color_settings
        color_settings_full = {}
        for char in color_setting:
            if color_setting[char]['color'] == 'none':
                color_settings_full[char] = 'none'
            elif color_setting[char]['color'].startswith('#'):
                color_settings_full[char] = color_setting[char]['color']
            else:
                color_full = convert_color_name(color_setting[char]['color'], 'full', True)
                if color_full is None:
                    color_full = '#000000'
                color_settings_full[char] = color_full

        self.color_settings_full = color_settings_full

    def xpm_to_ndarray(self):
        global import_numpy
        if not import_numpy:
            import numpy as np
            import_numpy = True

        self.get_color_settings_full()

        width = self.info['width']
        height = self.info['height']
        cpp = self.info['char_per_pixel']
        # RGBA
        data = np.zeros((height, width, 4), dtype=np.uint8)
        for i in range(height):
            for j in range(width):
                char = self.body[i][j*cpp:(j+1)*cpp]
                col_id = self.color_settings_full[char]
                if col_id == 'none':
                    data[i][j] = [0, 0, 0, 0]
                else:
                    r = int(col_id[1:3], 16)
                    g = int(col_id[3:5], 16)
                    b = int(col_id[5:7], 16)
                    data[i][j] = [r,g,b, 255]

        self.ndarray = data

    def get_vim_setings(self, gui=True):
        if gui: term = 'gui'
        else: term = 'cterm'

        match_cluster = 'syntax cluster Xpmcolors contains='
        if gui:
            color_setting = self.color_settings
        else:
            self.get_color_settings_full()
            color_setting = self.color_settings_full

        self.vim_settings = []
        for i,char in enumerate(color_setting):
            self.vim_settings.append({})
            if gui:
                col = color_setting[char]['color'].upper()
            else:
                col = color_setting[char].upper()
            if col == 'NONE':
                # get Normal highlight if possible.
                hi_cmd  = 'try | '
                hi_cmd += 'highlight link Xpmcolor{:d} Normal | '.format(i)
                hi_cmd += 'highlight Xpmcolor{:d} {}fg=bg | '.format(i, term)
                hi_cmd += 'catch | '
                hi_cmd += 'highlight Xpmcolor{:d} {}fg=NONE {}bg=NONE | '.format(i, term, term)
                hi_cmd += 'endtry'
            elif gui:
                hi_cmd = 'highlight Xpmcolor{:d} {}fg={} {}bg={}'.format(i, term, col, term, col)
            else:
                r = int(col[1:3], 16)
                g = int(col[3:5], 16)
                b = int(col[5:7], 16)
                col = convert_fullcolor_to_256(r, g, b)
                hi_cmd = 'highlight Xpmcolor{:d} {}fg={} {}bg={}'.format(i, term, col, term, col)
            self.vim_settings[-1]['highlight'] = hi_cmd

            for sp_char in "' \" $ . ~ ^ / [ ]".split(' '):
                if sp_char in char:
                    char = char.replace(sp_char, '\\'+sp_char)
            match_cmd = 'syntax match Xpmcolor{:d} /{}/ contained'.format(i, char)
            self.vim_settings[-1]['match'] = match_cmd

            match_cluster += 'Xpmcolor{:d},'.format(i)
        match_cluster = match_cluster[:-1]
        self.vim_finally = match_cluster

if __name__ == '__main__':
    import sys
    import matplotlib.pyplot as plt
    xpm_file = sys.argv[1]
    XPM = XPMLoader(xpm_file)
    XPM.xpm_to_ndarray()
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.imshow(XPM.ndarray)
    ax.grid(False)
    ax.set_xticks([])
    ax.set_yticks([])
    plt.show()

