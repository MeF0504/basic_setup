let yn = input('update setup? y/[n]: ')
if yn == 'y'
    if exists(':Terminal') == 2
        Terminal -win S update_setup
    else
        echo 'Terminal does not exist'
    endif
    call meflib#set('qrun_finished', 1)
else
    call meflib#set('qrun_finished', 0)
endif
