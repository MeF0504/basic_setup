#! /usr/bin/env python

##reference http://itchyny.hatenablog.com/entry/20130214/1360847516

import curses
from mycurses import *
import time

def get_data(max_y,max_x):
    import numpy as np
    m_size = np.min([max_x,max_y])
    size = int(m_size*0.4)
    #(x^2+y^2-1) = x^2y^3
    x = np.arange(0.0,1.14,0.01)
    yp = (x**(2.0/3)+np.sqrt(x**(4.0/3)-4*x**2+4))/2.0
    #x = np.arange(1.2,0,-0.01)
    x2 = x[::-1]
    ym = (x2**(2.0/3)-np.sqrt(x2**(4.0/3)-4*x2**2+4))/2.0
    y = np.r_[yp,ym]
    x = np.r_[x,x2]
    x = x[y==y]
    y = y[y==y]
    del yp
    del ym
    del x2
    #print x,y
    x = (x*size).astype(int)
    y = (y*size).astype(int)
    x[0] -= 1
    return x,y

ay,ax,iy,ix = getsize()

try:
    x,y = get_data(ay,ax)
except:
    x = [0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,4,  4,  4,  4,  4,  4,  4,  4,  5,  5,  5,  5,  5,  5,  5,  5,  6,6,  6,  6,  6,  6,  6,  6,  6,  7,  7,  7,  7,  7,  7,  7,  7,  8,8,  8,  8,  8,  8,  8,  8,  9,  9,  9,  9,  9,  9,  9,  9,  9, 10,10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12,12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,12, 12, 12, 12, 12, 12, 12, 12, 12, 11, 11, 11, 11, 11, 11, 11, 11,10, 10, 10, 10, 10, 10, 10, 10,  9,  9,  9,  9,  9,  9,  9,  9,  9,8,  8,  8,  8,  8,  8,  8,  8,  7,  7,  7,  7,  7,  7,  7,  7,  6,6,  6,  6,  6,  6,  6,  6,  6,  5,  5,  5,  5,  5,  5,  5,  5,  4,4,  4,  4,  4,  4,  4,  4,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,2,  2,  2,  2,  2,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,0,  0,  0,  0,  0,  0,  0]
    y = [11,  12,  12,  12,  12,  12,  12,  13,  13,  13,  13,  13,  13,13,  13,  13,  13,  13,  13,  13,  13,  14,  14,  14,  14,  14,14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,14,  14,  14,  13,  13,  13,  13,  13,  13,  13,  13,  13,  13,13,  13,  12,  12,  12,  12,  12,  12,  12,  12,  11,  11,  11,11,  11,  10,  10,  10,  10,   9,   9,   8,   8,   4,   4,   3,3,   2,   2,   1,   1,   1,   1,   0,   0,   0,   0,   0,   0,0,   0,  -1,  -1,  -1,  -1,  -1,  -2,  -2,  -2,  -2,  -2,  -2,-3,  -3,  -3,  -3,  -3,  -3,  -3,  -4,  -4,  -4,  -4,  -4,  -4,-4,  -5,  -5,  -5,  -5,  -5,  -5,  -5,  -5,  -6,  -6,  -6,  -6,-6,  -6,  -6,  -6,  -6,  -6,  -7,  -7,  -7,  -7,  -7,  -7,  -7,-7,  -7,  -7,  -8,  -8,  -8,  -8,  -8,  -8,  -8,  -8,  -8,  -8,-8,  -8,  -9,  -9,  -9,  -9,  -9,  -9,  -9,  -9,  -9,  -9,  -9,-9, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,-11, -11, -11, -11, -11, -11, -12]
    #print len(x),len(y)
clear()
#print getsize()
zero_x = (ax+ix)/2
zero_y = (ay+iy)/2
#print zero_x,zero_y
#put(zero_x,zero_y,'*')
for i in range(len(x)):
    #print zero_x+x[i],zero_y+y[i]
    put(zero_x-x[i],zero_y-y[i]/2,'*')
    put(zero_x+x[i],zero_y-y[i]/2,'*')
    time.sleep(0.03)

"""
xlist = range(10)
ylist = range(10)
for x in xlist:
    for y in ylist:
        put(x*3,y*3,'*')
        time.sleep(0.05)

import curses
import locale
#print 'a'

def c_main(args):

    locale.setlocale(locale.LC_ALL,"")
    try:
        stdscr = curses.initscr()
        curses.noecho()
        #curses.init_color(5,255,160,167)

        max_y, max_x = stdscr.getmaxyx()
        min_y, min_x = stdscr.getbegyx()
        zero_y = (min_y+max_y)/2
        zero_x = (min_x+max_x)/2
        #print 'zero',zero_x,zero_y

        xlist = range(10)
        ylist = range(10)
        for x in xlist:
            for y in ylist:
                stdscr.addstr(zero_y+y,zero_x+x,'*')#,curses.color_pair(5))
                #stdscr.getch()

        stdscr.addstr(zero_y,zero_y,'*')
        stdscr.getch()
        curses.endwin()
    except:
        curses.endwin()

#curses.wrapper(c_main)
"""
