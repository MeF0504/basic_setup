@echo off

where git
rem https://qiita.com/plcherrim/items/8edf3d3d33a0ae86cb5c
if errorlevel 1 (
    echo "git" not found
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
git fetch
git merge

python3 setup.py {}

pause
