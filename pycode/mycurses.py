
def put(x,y,str):
    print "\033[%d;%dH%s\n" % (y,x,str)

def clear():
    print "\033[2J"

def getsize():
    import curses

    stdscr = curses.initscr()
    max_y,max_x = stdscr.getmaxyx()
    min_y,min_x = stdscr.getbegyx()
    curses.endwin()
    return max_y,max_x,min_y,min_x

clear()
put(33,22,'a')
put(42,22,'a')

#clear()
#print getsize()
#for i in range(40):
#    put(i,i,str(i))

