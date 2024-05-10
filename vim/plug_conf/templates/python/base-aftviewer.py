import argparse
from pathlib import Path

from aftviewer import Args, help_template


def add_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument()


def show_help() -> None:
    helpmsg = help_template('{{_expr_:expand("%:t:r")}}', 'description.', add_args)
    print(helpmsg)


def main(fpath: Path, args: Args):
    pass
