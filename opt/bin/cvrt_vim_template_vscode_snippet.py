#! /usr/bin/env python3

import os
import re
import argparse
from pathlib import Path


def main(args):
    for p, ds, fs in os.walk(args.dir):
        for f in fs:
            path = Path(p)/f
            title = path.stem
            scope = path.parent.name
            prefix = title[title.find('-')+1:]
            body = ""
            cnt = 1
            input_dir = {}
            with open(path, 'r') as f:
                for line in f:
                    line = line.replace("{{_cursor_}}", "${0}")
                    pat = re.search("{{.*?}}", line)
                    while pat is not None:
                        tmp = line[pat.start()+2:pat.end()-2]
                        if "_input_" in tmp:
                            var = tmp.split(':')[1]
                            if var not in input_dir:
                                input_dir[var] = cnt
                                cnt += 1
                            line = re.sub("{{_input_:.*?}}",
                                          f"${{{input_dir[var]}}}",
                                          line, count=1)
                        else:
                            line = re.sub("{{.*?}}", "", line)
                        pat = re.search("{{.*?}}", line)
                    line = line.replace("\\", "\\\\")
                    line = line.replace("\n", "")
                    if len(line) != 0:
                        body += f'\t"{line}",\n'
            ret = '''"{}": {{
"scope": "{}",
"prefix": "{}",
"body": [
{}],
"description": "{}"
}},'''.format(f"{title}-{scope}", scope, prefix, body, title)
            print(ret)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('dir', help='vim template directory')
    args = parser.parse_args()
    main(args)
