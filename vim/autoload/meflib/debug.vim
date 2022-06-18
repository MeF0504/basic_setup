"vim script encording setting
scriptencoding utf-8

let s:init = 1
" debug 用
function! meflib#debug#debug_log(dbgmsg, tag) abort
    " dbgmsg: debug message,
    " tag:    tag string (used to idnetify type of debug message),

    " set file name to write debug message,
    let debug_log_file = meflib#get('log_file', getcwd()..'/debug_log.txt')

    if s:init
        let flag = ''
    else
        let flag = 'a'
    endif
    if exists('*strftime')
        let time = strftime("%m/%d %H:%M:%S")
    else
        let time = ""
    endif
    if empty(a:dbgmsg)
        let db_print = ["###debug-"..a:tag."### ".."@ "..expand("<sfile>").." "..time]
    else
        let db_print =  ["###debug-".a:tag."### "..time]
        let db_print += split(a:dbgmsg, '\n', 1)
    endif
    let db_print += ['']

    call writefile(db_print, debug_log_file, flag)

    let s:init = 0
endfunction

