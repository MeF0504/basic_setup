#! /usr/bin/env python3

### usage rm_debug.py /path/to/dir

### remove lines between "### DEBUG START" and "### DEBUG END"
### comment out characters is depend on file type; python->#, vim->"
### old files are stored in legacy/<today>/

import os
import sys
import re
import glob
from datetime import date
import shutil

debug_str_st = "... DEBUG START"
debug_str_end = "... DEBUG END"

def main():
    if len(sys.argv) < 2:
        print('''this command required input directory.
usage: rm_debug.py directory''')
        return 0

    in_dir = os.path.expanduser(sys.argv[1])
    if not os.path.exists(in_dir):
        print('input directory "{}" doesn\'t exist.'.format(in_dir))

    tdy = "%02d%02d%02d" % (date.today().year, date.today().month, date.today().day)
    copy_dir = os.path.join(in_dir, 'legacy', tdy)
    if not os.path.exists(copy_dir):
        os.makedirs(copy_dir)

    for fy in glob.glob(os.path.join(in_dir, '**', '*'), recursive=True):
        # print(fy)
        if os.path.isdir(fy):
            continue

        # check there are start line and end line.
        is_debug_file = 0
        try:
            with open(fy, 'r') as f:
                for line in f:
                    if re.match(debug_str_st, line):
                        is_debug_file = 1
                    if re.match(debug_str_end, line) and is_debug_file==1:
                        is_debug_file = 2
        except UnicodeDecodeError as e:
            continue

        # delete debug lines
        debug_line = False
        if is_debug_file == 2:
            raw_file = os.path.join(copy_dir, os.path.basename(fy))
            shutil.move(fy, raw_file)
            dst_f = open(fy, 'w')
            with open(raw_file, 'r') as f:
                for line in f:
                    if re.match(debug_str_st, line):
                        debug_line = True
                        continue
                    if re.match(debug_str_end, line) and debug_line:
                        debug_line = False
                        continue
                    if not debug_line:
                        print(line.replace('\n', ''), file=dst_f)
            dst_f.close()

if __name__ == '__main__':
    main()

