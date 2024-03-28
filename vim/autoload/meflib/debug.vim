"vim script encording setting
scriptencoding utf-8

let s:debug_log_file = ""
function! meflib#debug#set_debug(filename)
    " set file name to write debug message
    let s:debug_log_file = a:filename
    call writefile(["start debugging"], s:debug_log_file, '')
endfunction

" debug 用
function! meflib#debug#debug_log(dbgmsg, tag) abort
    " dbgmsg: debug message,
    " tag:    tag string (used to idnetify type of debug message),
    if empty(s:debug_log_file)
        return
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

    call writefile(db_print, s:debug_log_file, 'a')
endfunction

