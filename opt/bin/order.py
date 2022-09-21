#! /usr/bin/env python3

import argparse
import random


def main(args):
    L = len(args.list)
    arg_list = args.list
    for i in range(L):
        num = int(random.random()*(L-i))
        val = arg_list.pop(num)
        print(val)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
            description="order the given arguments randomly.")
    parser.add_argument('list', help='ordering list', nargs='*')
    args = parser.parse_args()
    main(args)
