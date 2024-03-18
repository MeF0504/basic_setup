#! /usr/bin/env python3

import vim
from pathlib import Path


def get_line(sfile, lstr):
    if sfile.is_file():
        with open(sfile, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f):
                line = line.replace("\n", "")
                if line == lstr:
                    return i+1
    return 0


def set_tag_info(tfile, taginfo):
    kinds = list(taginfo.keys())
    tfile = Path(tfile)
    if not tfile.is_file():
        return

    with open(tfile, 'r') as f:
        for i, line in enumerate(f):
            if line.startswith('!'):
                continue
            word = line.split("\t")[0]
            sfile = Path(line.split("\t")[1])
            ist = line.find('/^')
            iend = line.rfind('$/;"')
            if iend < 0:
                continue
            kind = line[iend+5]
            # print(i, iend, line[iend:], kind)
            lstr = line[ist+2:iend]
            lnum = get_line(sfile, lstr)
            sfile_str = str(sfile).replace("\\", "\\\\")
            res_str = f'{sfile_str}|{lnum}| {word} ({kind})'
            if kind in kinds:
                vim.command(f'call add(s:taginfo["{kind}"], "{res_str}")')
            else:
                vim.command(f'let s:taginfo["{kind}"] = ["{res_str}"]')
                kinds.append(kind)
