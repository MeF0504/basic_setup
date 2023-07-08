#! /usr/bin/env python3

from pathlib import Path
import argparse
import json

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

    img = Image.open(img_file)
    fig = px.imshow(img)

    with open(json_file, 'r', encoding='utf-8') as f:
        txt_list = json.load(f)
    for t in txt_list:
        if "opt" in t:
            opt = t["opt"]
        else:
            opt = {}
        put_text(fig, t['x'], t['y'], t['text'], **opt)

    if args.output is not None:
        fig.write_html(args.output)
    fig.show()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('img', help='input image')
    parser.add_argument('json', help='json file of input text list')
    parser.add_argument('--output', '-o', help='output file')
    args = parser.parse_args()
    main(args)
