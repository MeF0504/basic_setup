# basic_setup

This is my git repository including basic configuration files (i.e. dot files),
self-made commands and libraries, and vim setting files.

- shell rc files, git config files, etc. -> `config`
- self-made scripts -> `opt`
- vim setting files -> `vim`

## Download
```vim
git clone --recursive https://github.com/MeF0504/basic_setup.git
# or
git clone --recursive git@github.com:MeF0504/basic_setup.git
```

## Install

`python3 setup.py`
- `--prefix` specifies the install directory of items in `opt`
- `--vim_prefix` specifies the install directory of items in `vim`
- `--download` download `git-prompt.sh` for bash and `vim-plug` for vim.

Run `python3 setup.py -h` for more details.

### Optional Install
`pip install -r config/requirements.txt`
