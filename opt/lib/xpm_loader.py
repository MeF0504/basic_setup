
import re

from local_lib_color import convert_color_name, convert_fullcolor_to_256

import_numpy = False

class XPMLoader():
    def __init__(self):
        self.xpms = []

    def load_xpm(self, xpm_file):
        res = ''
        com_line = 0

        with open(xpm_file) as f:
            for line in f:
                line = line.replace("\t", "")
                # // comment
                if re.match(" *//", line) is not None: continue
                # ~~~ */
                if re.match(".*\*/ *\n", line) is not None:
                    if com_line == 1:
                        com_line = 0
                        continue
                    elif re.match(" */\*", line) is not None:
                        continue
                # /* ~~~
                if re.match(" */\*", line) is not None:
                    com_line = 1
                    continue
                # comment line
                if com_line == 1:
                    continue
                tmpline = line.replace("\n", "")
                res += tmpline

        res = res[res.find('{')+1:res.rfind('}')]
        res = eval("["+res+']')
        width, height, colors, byte_per_col = [int(x) for x in res[0].split(' ', 3)]
        info = { \
                'width'  : width, \
                'height' : height, \
                'colors' : colors, \
                'byte_per_col' : byte_per_col \
                }
        # print(width, height, colors, byte_per_col)

        tmp_color_settings = res[1:colors+1]
        color_settings = {}
        for cs in tmp_color_settings:
            # char = cs[0]
            # color = cs[cs.rfind(' ')+1:]
            char, color = cs.split(' c ')
            color_settings[char] = color
        # print(color_settings)

        body = res[colors+1:]
        # print(body[:3])
        assert height == len(body)
        assert width*byte_per_col == len(body[0])

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
                if color_setting[char] == 'None':
                    color_settings_full[char] = 'None'
                elif color_setting[char].startswith('#'):
                    color_settings_full[char] = color_setting[char]
                else:
                    color_full = convert_color_name(color_setting[char].lower(), 'full', True)
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
            byte = xpm['info']['byte_per_col']
            # RGBA
            data = np.zeros((height, width, 4), dtype=int)
            for i in range(height):
                for j in range(width):
                    char = xpm['body'][i][j*byte:(j+1)*byte]
                    col_id = xpm['color_settings_full'][char]
                    if col_id == 'None':
                        data[i][j] = [0, 0, 0, 0]
                    else:
                        r = int(col_id[1:3], 16)
                        g = int(col_id[3:5], 16)
                        b = int(col_id[5:7], 16)
                        data[i][j] = [r,g,b, 255]

            xpm['ndarray'] = data

if __name__ == '__main__':
    import sys
    import matplotlib.pyplot as plt
    xpm_file = sys.argv[1]
    xpms = XPMLoader()
    xpms.load_xpm(xpm_file)
    xpms.xpm_to_ndarray()
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.imshow(xpms.xpms[0]['ndarray'])
    ax.grid(False)
    ax.set_xticks([])
    ax.set_yticks([])
    plt.show()

