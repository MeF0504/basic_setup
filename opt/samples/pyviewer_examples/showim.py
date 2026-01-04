
from pathlib import Path

try:
    from PIL import Image
    from PIL.ExifTags import TAGS, GPSTAGS
except ImportError as e:
    print(type(e).__name__, e)
    is_pil = False
else:
    is_pil = True

from aftviewer import (Args, show_image_file, help_template, args_chk,
                       add_args_imageviewer, add_args_verbose, print_warning)


def add_args(parser):
    add_args_imageviewer(parser)
    add_args_verbose(parser, help='show verbose EXIF info.')


def show_help():
    helpmsg = help_template('showim', 'show an image file.', add_args)
    print(helpmsg)


def show_gps(gps_info):
    gps = {}
    for tag, val in gps_info.items():
        gps[GPSTAGS.get(tag, tag)] = val

    res = []
    for latlon, NE in zip('Latitude Longitude'.split(), 'NE'):
        larr = gps[f'GPS{latlon}']
        if len(larr) == 3:
            # deg/min/sec
            lval = larr[0] + larr[1]/60.0 + larr[2]/3600
        else:
            # deg/min/sec 分子, deg/min/sec 分母？
            lval = larr[0][0]/larr[1][0] + (larr[0][1]/larr[1][1])/60.0 + \
                (larr[0][2]/larr[1][2])/3600.0
        if gps[f'GPS{latlon}Ref'] != NE:
            lval = 0-lval
        res.append(f'{lval:.06f}')

    return ', '.join(res)


def main(fpath: Path, args: Args):
    if is_pil:
        print('EXIF data')
        verbose = args_chk(args, 'verbose')
        try:
            img_data = Image.open(fpath)
            if verbose:
                img_exif = img_data._getexif()
            else:
                img_exif = img_data.getexif()
            for key, val in img_exif.items():
                if key in TAGS:
                    keyname = TAGS[key]
                else:
                    keyname = f'0x{key:04x}'
                if verbose and keyname == 'GPSInfo':
                    print(f' {keyname}: {show_gps(val)}')
                else:
                    print(f' {keyname}: {val}')
        except Exception as e:
            print_warning('Cannot read EXIF data.')
            print_warning(f'{type(e).__name__}, {e}')
    show_image_file(str(fpath), args)
