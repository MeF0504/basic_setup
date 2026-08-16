#! /usr/bin/env python3

import os
import argparse
import json
import pickle
from datetime import datetime
from pathlib import Path
from typing import Iterable
from pprint import pprint

import numpy as np
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient import discovery

TMPDATA = Path('~/.config/meflib/youtube/data.pkl').expanduser()
SCOPES = ["https://www.googleapis.com/auth/youtube.readonly"]


def chunked(xs: list[str], n: int) -> Iterable[list[str]]:
    for i in range(0, len(xs), n):
        yield xs[i:i + n]


def conv_sec(time_str: str) -> tuple[int]:
    if 'H' in time_str:
        tmp = time_str.split('H')
        assert len(tmp) == 2, f'something strange (H), {tmp}'
        hour = int(tmp[0])
        time_str2 = tmp[1]
    else:
        hour = 0
        time_str2 = time_str

    if 'M' in time_str2:
        tmp = time_str2.split('M')
        assert len(tmp) == 2, f'something strange (M), {tmp}'
        minute = int(tmp[0])
        time_str3 = tmp[1]
    else:
        minute = 0
        time_str3 = time_str2

    if 'S' in time_str3:
        tmp = time_str3.split('S')
        assert len(tmp) == 2, f'something strange (S), {tmp}'
        sec = int(tmp[0])
    else:
        sec = 0

    return hour, minute, sec


def update() -> bool:
    TMPDATA.parent.mkdir(exist_ok=True)
    conf_file = TMPDATA.parent/'config.json'
    if not conf_file.is_file():
        print('config file is not found.')
        return False

    with open(conf_file, 'rb') as f:
        conf = json.load(f)

    os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"

    api_service_name = "youtube"
    api_version = "v3"
    cs_file = conf['client_secrets']
    playid = conf['playlistId']

    flow = InstalledAppFlow.from_client_secrets_file(cs_file, SCOPES)
    # credentials = flow.run_console()
    credentials = flow.run_local_server(port=0)
    youtube = discovery.build(api_service_name, api_version,
                              credentials=credentials)

    next_page_token = None
    video_ids = []
    while True:
        request = youtube.playlistItems().list(part="contentDetails",
                                               maxResults=50,
                                               playlistId=playid,
                                               pageToken=next_page_token,
                                               )
        response = request.execute()

        for item in response.get("items", []):
            content = item.get("contentDetails", {})
            video_id = content.get("videoId")
            if video_id:
                video_ids.append(video_id)

        next_page_token = response.get("nextPageToken")
        if not next_page_token:
            break

    details = {}
    for vids in chunked(video_ids, 50):
        request = youtube.videos().list(part="snippet,contentDetails",
                                        id=','.join(vids), maxResults=50,)
        response = request.execute()

        for item in response.get('items', []):
            video_id = item.get('id')
            if not video_id:
                continue
            snippet = item.get('snippet', {})
            content = item.get('contentDetails', {})
            details[video_id] = {'title': snippet.get('title', ''),
                                 'duration': content.get('duration', ''),
                                 'published': snippet.get('publishedAt', ''),
                                 'desc': snippet.get('description', ''),
                                 }
            if False:
                pprint(item)
                input('>>> Enter to continue')
    with open(TMPDATA, 'wb') as f:
        pickle.dump(details, f)

    print(f'data saved at {TMPDATA}, total length={len(details)}.')
    return True


def main(args):
    ret = True
    if args.update:
        ret = update()
    elif not TMPDATA.exists():
        ret = update()
    if not ret:
        print('failed to update data.')
        return

    with open(TMPDATA, 'rb') as f:
        data = pickle.load(f)

    video_ids = []
    pubs = []
    pubs_sec = []
    durs = []
    durs_sec = []
    for vid in data:
        video_ids.append(vid)
        pub = datetime.fromisoformat(data[vid]['published'])
        pubs.append(pub)
        pubs_sec.append(pub.timestamp())
        dur = conv_sec(data[vid]['duration'][2:])
        durs.append(dur)
        durs_sec.append(3600*dur[0]+60*dur[1]+dur[0])

    if args.sort == 'none':
        indices = np.arange(len(video_ids))
    elif args.sort == 'duration':
        indices = np.argsort(durs_sec)
    elif args.sort == 'publish':
        indices = np.argsort(pubs)
    if args.reverse:
        indices = indices[::-1]

    for i, idx in enumerate(indices):
        vid = video_ids[idx]
        title = data[vid]['title']
        url = f'https://www.youtube.com/watch?v={vid}'
        dur = durs[idx]
        time_str = f'{dur[0]:02d}:{dur[1]:02d}:{dur[2]:02d}'
        pub = pubs[idx]
        date_str = pub.strftime('%Y/%m/%d')
        print(f'{i+1}: {title}')
        print(f'\tPlay: {time_str}  Publish: {date_str}')
        print(f'\t{url}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--sort', help='specify what to sort',
                        choices=['duration', 'publish', 'none'],
                        default='duration')
    parser.add_argument('--update', help='update the youtube list data.',
                        action='store_true')
    parser.add_argument('-v', '--reverse', help='display in descending order.',
                        action='store_true')
    args = parser.parse_args()
    main(args)
