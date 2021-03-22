#! /usr/bin/env python3

from __future__ import print_function

BG = {'k':'\033[40m','w':'\033[47m','r':'\033[41m','g':'\033[42m','b':'\033[44m','m':'\033[45m','c':'\033[46m','y':'\033[43m'}
FG = {'k':'\033[30m','w':'\033[37m','r':'\033[31m','g':'\033[32m','b':'\033[34m','m':'\033[35m','c':'\033[36m','y':'\033[33m'}
END = '\033[0m'

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

# for vim color test
def isdark(r,g,b):
    # cond = (r+g+b<7) and (max([r,g,b])<4)

    # cond = (r**2+g**2+b**2 < 5**2)

    # if r < 4:
    #     cond = (g==0 or g*g+b*b < 3**2)
    #     cond = (g<3 and g+b < 6)
    # else:
    #     cond = g*g+b*b < (7-r)**2

    w_r, w_g, w_b = (0.299,0.587,0.114)
    cond = (r*w_r+g*w_g+b*w_b)/(w_r+w_g+w_b) < 2.1

    return cond

def main_test(num):
    print('system colors')
    for i in range(8):
        if num == 1:
            if i%2 == 0:    # even
                tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
            else:           # odd
                tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print()
    for i in range(8,16):
        if num == 1:
            if i%2 == 0:    # even
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
                if num == 0:
                    tmp_st = '  '
                elif num == 1:
                    if i%2 == 0:    # even
                        tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
                    else:           # odd
                        tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
                else:
                    # tmp_st = '{}{:02x}{}'.format(FG256(36*((r+3)%6)+6*((g+3)%6)+(b+3)%6+16), i, END)
                    if isdark(r, g, b):
                        tmp_st = '{}{:02x}{}'.format(FG256(255), i, END)
                    else:
                        tmp_st = '{}{:02x}{}'.format(FG256(234), i, END)
                print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
            print(' ', end='')
        print()
    print()

    print('gray scales')
    st = 6*6*6+16
    for i in range(st, 256):
        if num == 1:
            tmp_st = '{}{:02x}{}'.format(FG256(255+st-i), i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print('\n')

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--num', help='0... no fg, 1... show number, 2... is_dark', choices=[0,1,2], type=int)
    args = parser.parse_args()

    if hasattr(args, 'num') and (args.num is not None):
        num = args.num
    else:
        num = 0
    main_test(num)

