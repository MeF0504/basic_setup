"vim script encording setting
scriptencoding utf-8

" debug 用
function! meflib#debug#debug_log(dbgmsg, tag) abort
    " dbgmsg: debug message,
    " tag:    tag string (used to idnetify type of debug message),

    " set file name to write debug message,
    let debug_log_file = meflib#basic#get_local_var('log_file', getcwd()..'/debug_log.txt')

    if exists('*strftime')
        let time = strftime("%m/%d %H:%M:%S")
    else
        let time = ""
    endif
    if a:dbgmsg == ""
        let db_print = ["###debug-"..a:tag."### ".."@ "..expand("<sfile>").." "..time]
    else
        let db_print =  ["###debug-".a:tag."### "..time]
        let db_print += split(a:dbgmsg, '\n', 1)
    endif
    let db_print += ['']

    call writefile(db_print, debug_log_file, 'a')
endfunction
