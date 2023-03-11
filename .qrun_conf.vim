let yn = input('update setup? y/[n]: ')
if yn == 'y'
    if exists(':Terminal') == 2
        if executable('update_setup')
            Terminal -win S update_setup --nopull
        else
            " assume windows
            Terminal -win S python3 tmp\update_setup --nopull
        endif
    else
        echo 'Terminal does not exist'
    endif
    call meflib#set('qrun_finished', 1)
else
    call meflib#set('qrun_finished', 0)
endif
