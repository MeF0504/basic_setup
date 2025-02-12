#! /usr/bin/env python3

from pathlib import Path


def main():
    res = []
    base_dir = Path(__file__).parent.parent.parent
    doc_file = base_dir/'doc/meflib_test.jax'
    for fy in base_dir.glob('**/*.vim'):
        # print(fy)
        if 'templates' in str(fy):
            continue
        is_doc = False
        with open(fy, 'r') as f:
            for ln in f:
                if ln.startswith('" DOC '):
                    is_doc = True
                    assert len(ln.replace('\n', '').split(' ')) == 4, \
                        f"failed to set param: {fy}, {ln}"
                    _, _, doc_type, name = ln.replace('\n', '').split(' ')
                    details = {'type': doc_type, 'name': name, 'cont': []}
                elif ln.startswith('" DOCEND'):
                    is_doc = False
                    res.append(details)
                elif is_doc:
                    details['cont'].append(ln[2:-1])
    # print(res)
    doc_cmd = ""
    doc_func = ""
    doc_opt = ""
    for conf in res:
        if conf['type'] == 'COMMANDS':
            cmd_det = conf['cont'][0]
            sp_num = 80-len(conf['name'])-3
            doc_cmd += f'{cmd_det:<{sp_num}s}*:{conf["name"]}*\n'
            for txt in conf['cont'][1:]:
                doc_cmd += txt+'\n'
            doc_cmd += '\n'
        elif conf['type'] == 'FUNCTIONS':
            func_det = conf['cont'][0]
            sp_num = 80-len(conf['name'])-2
            doc_func += f'{func_det:<{sp_num}s}*{conf["name"]}*\n'
            for txt in conf['cont'][1:]:
                doc_func += txt+'\n'
            doc_func += '\n'
        elif conf['type'] == 'OPTIONS':
            sp_num = 80-len(conf['name'])-2-len('meflib-')
            doc_opt += f'{conf["name"]:<{sp_num}s}*meflib-{conf["name"]}*\n'
            for txt in conf['cont']:
                doc_opt += txt+'\n'
            doc_opt += '\n'

    doc = f"""
*meflib.txt*    local library of vim script. 色々あって日本語／英語混在
both Japanese and English
vimは1行目にマルチバイトがあるかどうかでエンコーディングを判別するらしい
|E670| *meflib.jax*

==============================================================================
CONTENTS                                                       *meflib-contents*

Introduction	|meflib-introduction|
Commands	|meflib-commands|
Functions	|meflib-functions|
Options		|meflib-options|
Memo		|meflib-memo|
License		|meflib-license|

==============================================================================
INTRODUCTION                                               *meflib-introduction*

local library of vim scripts for Mef0504 (https://github.com/MeF0504)

==============================================================================
COMMANDS                                                       *meflib-commands*

{doc_cmd}
==============================================================================
FUNCTIONS                                                     *meflib-functions*

{doc_func}
==============================================================================
OPTIONS                                                         *meflib-options*

{doc_opt}
==============================================================================
MEMO                                                               *meflib-memo*

* python  |meflib-pythonmemo.jax|
* shell  |meflib-shellmemo.jax|
* strftime |meflib-strftime.jax|
* vim  |meflib-vimmemo.jax|

==============================================================================
LICENSE                                                         *meflib-license*

The MIT License (https://github.com/MeF0504/basic_setup/blob/master/LICENSE)

vim:tw=78:ts=8:ft=help:norl:noet:fen:noet:
"""
    print(doc)
    with open(doc_file, 'w') as f:
        f.write(doc)



if __name__ == '__main__':
    main()
