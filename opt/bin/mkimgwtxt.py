#! /usr/bin/env python3

from pathlib import Path
import argparse
import json
import copy

from PIL import Image
import plotly.express as px

from pymeflib.plot2 import put_text


def main(args):
    img_file = Path(args.img)
    if not img_file.is_file():
        print('image file is not exists.')
        return
    json_file = Path(args.json)
    if not json_file.is_file():
        print('json file is not exists.')
        return

    add_text(img_file, json_file, args)
    if args.append:
        update_json(json_file)
        add_text(img_file, json_file, args)


def update_json(json_file):
    with open(json_file, 'r', encoding='utf-8') as f:
        txt_list = json.load(f)
    print('type "quit" to quit')
    while True:
        x = input('x: ')
        if x == 'quit':
            break
        else:
            x = int(x)
        y = input('y: ')
        if y == 'quit':
            break
        else:
            y = int(y)
        txt = input('text: ')
        if txt == 'quit':
            break

        txt_list.append({'x': x, 'y': y, 'text': txt})

    with open(args.json, 'w', encoding='utf-8') as f:
        json.dump(txt_list, f, indent=4, ensure_ascii=False)


def add_text(img_file, json_file, args):
    img = Image.open(img_file)
    fig = px.imshow(img)

    with open(json_file, 'r', encoding='utf-8') as f:
        txt_list = json.load(f)
    if 'opt' in txt_list[0] and 'text' not in txt_list[0]:
        global_opt = txt_list[0]['opt']
        del txt_list[0]
    else:
        global_opt = {}
    for t in txt_list:
        if 'x' not in t or 'y' not in t or 'text' not in t:
            print('invalid setting: {}'.format(t))
            continue

        opt = copy.deepcopy(global_opt)
        if "opt" in t:
            opt.update(t['opt'])
        put_text(fig, t['x'], t['y'], t['text'], **opt)

    if args.output is not None:
        fig.write_html(args.output)
    fig.show()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('img', help='input image')
    parser.add_argument('json', help='{} {} {} {} {} {} {} {} {}'.format(
        'json file of input text list.',
        'This json file is composed of one list.',
        'Each component of this list is doctionary',
        'with keys of "x" (x pixel), "y" (y pixel),',
        '"text" (displayed text).',
        'If "opt": {} is also set, this dictionary is passed to',
        'the add_anotation (ref: https://plotly.com/python/text-and-annotations/).',
        'If the first item only has "opt" key, this is treated as global setting.',
        'sample: opt/samples/mkimgwtxt_sample.json',
        ))
    parser.add_argument('--output', '-o', help='output file')
    parser.add_argument('--append', '-a', help='do append mode.',
                        action='store_true')
    args = parser.parse_args()
    main(args)
