#! /usr/bin/env python3

import vim
from pathlib import Path


def get_line(sfile, lstr):
    with open(sfile, 'r') as f:
        for i, line in enumerate(f):
            line = line.replace("\n", "")
            if line == lstr:
                return i+1
    return 0


def set_tag_info(tfile):
    kinds = []
    tfile = Path(tfile)
    if not tfile.is_file():
        return

    with open(tfile, 'r') as f:
        for line in f:
            if line.startswith('!'):
                continue
            word = line.split("\t")[0]
            sfile = line.split("\t")[1]
            ist = line.find('/^')
            iend = line.rfind('$/;"')
            kind = line[iend+5]
            lstr = line[ist+2:iend]
            lnum = get_line(sfile, lstr)
            res_str = "{}|{:d}| {} ({})".format(sfile, lnum, word, kind)
            if kind in kinds:
                vim.command('call add(s:taginfo["{}"], "{}")'.format(kind, res_str))
            else:
                vim.command('let s:taginfo["{}"] = ["{}"]'.format(kind, res_str))
                kinds.append(kind)
