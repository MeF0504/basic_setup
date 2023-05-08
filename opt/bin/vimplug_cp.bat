@echo off
for /d %%d in (plugin autoload colors doc) do (
    if exist "%%d" (
        echo "copy %%d"
        if not exist "%homedrive%%homepath%\vimfiles\test\%%d" (
            mkdir "%homedrive%%homepath%\vimfiles\test\%%d"
        )
        xcopy /s /y "%%d" "%homedrive%%homepath%\vimfiles\test\%%d"
    )
)
