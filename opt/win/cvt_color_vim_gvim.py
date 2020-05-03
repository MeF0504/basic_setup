
import sys
import os

def cvt_256_fc(color):
    try:
        color = int(color)
    except ValueError:
        if color == 'None':
            return 'NONE'
        return color
    fc_256_file = os.path.join(os.path.dirname(sys.argv[0]), 'FullColor_256.txt')
    with open(fc_256_file, 'r') as f:
        line = f.readlines()[color+1]
    return line.split()[2]

def main():
    vim_color = sys.argv[1]
    gvim_color = sys.argv[2]

    gline = []
    with open(vim_color, 'r', encoding='utf-8') as vimf:
        for line in vimf:
            if 'cterm' in line:
                tmp_gline = line[:line.find('cterm')-1]
                for cterm in ['cterm=', 'ctermfg=', 'ctermbg=']:
                    if cterm in line:
                        bias = len(cterm)
                        st = line.find(cterm) + bias
                        end = line[st:].find(' ') + st
                        if st > end:
                            end = -1
                        opt = line[st:end]
                        tmp_gline += ' ' + cterm.replace('cterm', 'gui') + cvt_256_fc(opt)
                gline.append(tmp_gline)
            else:
                gline.append(line.replace('\n', ''))
            # print(gline[-1])

    with open(gvim_color, 'w', encoding='utf-8') as gvimf:
        for l in gline:
            print(l, file=gvimf)

    return

if __name__ == '__main__':
    main()
