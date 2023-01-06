
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '../lib'))
from pymeflib.color import convert_256_to_fullcolor as cvt_256_fc


def main():
    vim_color = sys.argv[1]
    gvim_color = sys.argv[2]

    gline = []
    with open(vim_color, 'r', encoding='utf-8') as vimf:
        for line in vimf:
            is_ended = False
            if 'cterm' in line:
                tmp_gline = line[:line.find('cterm')-1]
                for cterm in ['cterm=', 'ctermfg=', 'ctermbg=']:
                    if cterm in line:
                        bias = len(cterm)
                        st = line.find(cterm) + bias
                        end = line[st:].find(' ') + st
                        if st > end:
                            end = -1
                            is_ended = True
                        opt = line[st:end]
                        try:
                            opt = int(opt)
                        except ValueError:
                            if opt == 'None':
                                opt = 'NONE'
                        else:
                            opt = cvt_256_fc(opt)
                        tmp_gline += ' ' + cterm.replace('cterm', 'gui') + opt
                if not is_ended:
                    tmp_gline += line[end:]
                gline.append(tmp_gline.replace('\n', ''))
            else:
                gline.append(line.replace('\n', ''))

    with open(gvim_color, 'w', encoding='utf-8') as gvimf:
        for al in gline:
            print(al, file=gvimf)

    return


if __name__ == '__main__':
    main()
