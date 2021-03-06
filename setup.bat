@echo off

echo which "git", "sh" and "python";
which git
which sh
which python

echo;
set curdir=%~dp0
set vimcon=%homedrive%%homepath%\vimfiles\

if exist %vimcon%\dein\repos\github.com\Shougo\dein.vim (
    echo dein already exists.
) else (
    mkdir %vimcon%\dein\repos\github.com\Shougo\dein.vim\
    git clone https://github.com/Shougo/dein.vim %vimcon%\dein\repos\github.com\Shougo\dein.vim\
)
if exist %vimcon%\swp (
    echo swp exist.
) else (
    mkdir %vimcon%\swp
)
echo vimrc
copy %curdir%\vim\vimrc %homedrive%%homepath%\_vimrc

echo gvimrc
copy %curdir%\vim\gvimrc %homedrive%%homepath%\_gvimrc

echo rcdir
if exist %vimcon%\rcdir (
    echo rcdir exists.
) else (
    mkdir %vimcon%\rcdir
)
copy %curdir%\vim\rcdir\* %vimcon%\rcdir\

REM delete the current gvimrc_color.vim to check the new file is made.
set gvim_color=%vimcon%\rcdir\gvimrc_color.vim
if exist %gvim_color% (
    del %gvim_color%
)
python %curdir%\opt\win\cvt_color_vim_gvim.py %curdir%\vim\rcdir\vimrc_color.vim %gvim_color%
if exist %gvim_color% (
    echo make gvim color file
) else (
    echo Warning! ### making gvim color file failed.
)

echo;

echo ftplugin
if exist %vimcon%\ftplugin (
    echo ftplugin exists.
) else (
    mkdir %vimcon%\ftplugin
)
copy %curdir%\vim\ftplugin\* %vimcon%\ftplugin\

echo toml
if exist %vimcon%\toml (
    echo toml exists.
) else (
    mkdir %vimcon%\toml
)
copy %curdir%\vim\toml\* %vimcon%\toml\

echo bashrc
copy %curdir%\config\bashrc %homedrive%%homepath%\.bashrc

pause

