@echo off

set curdir=%~dp0
set vimcon=%homedrive%%homepath%\vimfiles\
rem if exist %vimcon%\dein\repos\github.com\Shougo\dein.vim (
rem     echo dein already exists.
rem ) else (
rem     mkdir %vimcon%\dein\repos\github.com\Shougo\dein.vim\
rem     git clone https://github.com/Shougo/dein.vim %vimcon%\dein\repos\github.com\Shougo\dein.vim\
rem )

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


pause

