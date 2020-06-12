#! /usr/bin/env python3

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
    if (r<3) and (g<3) and (b<3):
        return True
    elif (r+g+b<7) and (max([r,g,b])<4):
        return True
    else:
        return False

def main_test():
    print('system colors')
    for i in range(8):
        tmp_st = '  '
        # tmp_st = '{:02x}'.format(i)
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print()
    for i in range(8,16):
        tmp_st = '  '
        # tmp_st = '{:02x}'.format(i)
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print('\n')

    print('6x6x6 color blocks')
    for g in range(6):
        for r in range(6):
            for b in range(6):
                tmp_st = '  '
                # tmp_st = '{:02x}'.format(36*r+6*g+b+16)
                # tmp_st = '{}{:02x}{}'.format(FG256(36*((r+3)%6)+6*((g+3)%6)+(b+3)%6+16), 36*r+6*g+b+16, END)
                # if (3<r) and (3<g) and (3<b):
                #     tmp_st = '{}{}{}'.format(FG['k'], 'bk', END)
                print('{}{}{}'.format(BG256(36*r+6*g+b+16), tmp_st, END), end='')
            print(' ', end='')
        print()
    print()

    print('gray scales')
    st = 6*6*6+16
    for i in range(st, 256):
        tmp_st = '  '
        # tmp_st = '{:02x}'.format(i)
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print('\n')

if __name__ == '__main__':
    main_test()

