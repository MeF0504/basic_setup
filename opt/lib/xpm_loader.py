
import re
import sys

from local_lib_color import convert_color_name, convert_fullcolor_to_256

import_numpy = False

class XPMLoader():
    def __init__(self):
        self.xpms = []

    def load_xpm(self, xpm_file):
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

        self.xpms.append({\
                'file_name' : xpm_file, \
                'info' : info, \
                'color_settings' : color_settings, \
                'body' : body, \
                })

    def get_color_settings_full(self, index=None):
        if index is None:
            index = range(len(self.xpms))
        elif not hasattr(index, '__iter__'):
            index = [index]

        for i in index:
            xpm = self.xpms[i]
            if 'color_settings_full' in xpm:
                continue

            color_setting = xpm['color_settings']
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

            xpm['color_settings_full'] = color_settings_full

    def xpm_to_ndarray(self, index=None):
        global import_numpy
        if not import_numpy:
            import numpy as np
            import_numpy = True

        if index is None:
            index = range(len(self.xpms))
        elif not hasattr(index, '__iter__'):
            index = [index]

        self.get_color_settings_full(index)

        for i in index:
            xpm = self.xpms[i]
            if 'ndarray' in xpm:
                continue
            width = xpm['info']['width']
            height = xpm['info']['height']
            cpp = xpm['info']['char_per_pixel']
            # RGBA
            data = np.zeros((height, width, 4), dtype=np.uint8)
            for i in range(height):
                for j in range(width):
                    char = xpm['body'][i][j*cpp:(j+1)*cpp]
                    col_id = xpm['color_settings_full'][char]
                    if col_id == 'none':
                        data[i][j] = [0, 0, 0, 0]
                    else:
                        r = int(col_id[1:3], 16)
                        g = int(col_id[3:5], 16)
                        b = int(col_id[5:7], 16)
                        data[i][j] = [r,g,b, 255]

            xpm['ndarray'] = data

    def get_vim_setings(self, index=None, gui=True):
        if index is None:
            index = range(len(self.xpms))
        elif not hasattr(index, '__iter__'):
            index = [index]

        if gui: term = 'gui'
        else: term = 'cterm'

        self.get_color_settings_full(index)

        for i in index:
            xpm = self.xpms[i]
            if 'vim' in xpm:
                continue
            color_setting = xpm['color_settings_full']
            xpm['vim'] = []
            xpm_vim = xpm['vim']
            for j,char in enumerate(color_setting):
                xpm_vim.append({})
                col = color_setting[char].upper()
                if col == 'NONE':
                    # get Normal highlight if possible.
                    hi_cmd  = 'try | '
                    hi_cmd += 'highlight link Xpmcolor{:d} Normal | '.format(j)
                    hi_cmd += 'highlight Xpmcolor{:d} {}fg=bg | '.format(j, term)
                    hi_cmd += 'catch | '
                    hi_cmd += 'highlight Xpmcolor{:d} {}fg=NONE {}bg=NONE | '.format(j, term, term)
                    hi_cmd += 'endtry'
                elif not gui:
                    r = int(col[1:3], 16)
                    g = int(col[3:5], 16)
                    b = int(col[5:7], 16)
                    col = convert_fullcolor_to_256(r, g, b)
                    hi_cmd = 'highlight Xpmcolor{:d} {}fg={} {}bg={}'.format(j, term, col, term, col)
                else:
                    hi_cmd = 'highlight Xpmcolor{:d} {}fg={} {}bg={}'.format(j, term, col, term, col)
                xpm_vim[-1]['highlight'] = hi_cmd

                for sp_char in "' \" $ . ~ ^ / [ ]".split(' '):
                    if sp_char in char:
                        char = char.replace(sp_char, '\\'+sp_char)
                match_cmd = 'syntax match Xpmcolor{:d} /{}/ contained'.format(j, char)
                xpm_vim[-1]['match'] = match_cmd

if __name__ == '__main__':
    import sys
    import matplotlib.pyplot as plt
    xpm_file = sys.argv[1]
    XL = XPMLoader()
    XL.load_xpm(xpm_file)
    XL.xpm_to_ndarray()
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.imshow(XL.xpms[0]['ndarray'])
    ax.grid(False)
    ax.set_xticks([])
    ax.set_yticks([])
    plt.show()

