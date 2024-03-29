@echo off

echo where "git", "sh" and "python";
where git
rem https://qiita.com/plcherrim/items/8edf3d3d33a0ae86cb5c
if errorlevel 1 (
    echo "git" not found
    pause
    exit \b
)
where sh
if errorlevel 1 (
    echo "sh" not found
    pause
    exit \b
)
where python
if errorlevel 1 (
    echo "python" not found
    pause
    exit \b
)

echo;
set curdir=%~dp0
set vimcon=%homedrive%%homepath%\vimfiles\

if exist %vimcon%\dein\repos\github.com\Shougo\dein.vim (
    echo dein already exists.
) else (
    PowerShell -command "Invoke-WebRequest https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.ps1 -OutFile installer.ps1"
    rem Allow to run third-party script
    PowerShell -command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    PowerShell -command "./installer.ps1 ~/vimfiles/dein "
    del installer.ps1
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

:: REM delete the current gvimrc_color.vim to check the new file is made.
:: set gvim_color=%vimcon%\rcdir\gvimrc_color.vim
:: if exist %gvim_color% (
::     del %gvim_color%
:: )
:: python %curdir%\opt\win\cvt_color_vim_gvim.py %curdir%\vim\rcdir\vimrc_color.vim %gvim_color%
:: if exist %gvim_color% (
::     echo make gvim color file
:: ) else (
::     echo Warning! ### making gvim color file failed.
:: )

echo;

echo ftplugin
if exist %vimcon%\ftplugin (
    echo ftplugin exists.
) else (
    mkdir %vimcon%\ftplugin
)
copy %curdir%\vim\ftplugin\* %vimcon%\ftplugin\

echo autoload
if exist %vimcon%\autoload\meflib (
    echo autoload\meflib exists.
) else (
    mkdir %vimcon%\autoload\meflib
)
copy %curdir%\vim\autoload\* %vimcon%\autoload
copy %curdir%\vim\autoload\meflib\* %vimcon%\autoload\meflib

echo toml
if exist %vimcon%\toml (
    echo toml exists.
) else (
    mkdir %vimcon%\toml
)
copy %curdir%\vim\toml\* %vimcon%\toml\

echo posixshellrc and bashrc
copy %curdir%\config\posixShellRC %homedrive%%homepath%\.posixShellRC
copy %curdir%\config\bashrc %homedrive%%homepath%\.bashrc

pause

