scriptencoding utf-8

" Buffer にコマンドの出力結果をだす
" 補完
function! meflib#cmdout#cmp(arglead, cmdline, cursorpos) abort
    let cmdlines = split(a:cmdline, ' ', 1)
    let cmd_idx = match(cmdlines, 'C.*')
    if len(cmdlines) <= cmd_idx+2
        if a:arglead[0] == ":"
            " vim command
            return map(getcompletion(a:arglead[1:], "command"), '":"..v:val')
            " return ["a", "b", "c"]
        else
            " shell command
            return getcompletion(a:arglead, "shellcmd")
        endif
    else
        return getcompletion(a:arglead, "file")
    endif
endfunction

function! meflib#cmdout#main(...) abort
    if empty(a:000)
        echohl ErrorMsg
        echo "empty input"
        echohl None
        return
    endif
    if a:1[0] == ':'
        " vim command
        let cmd = join(a:000)
        let res = execute(cmd)->split("\n")
    else
        " shell command
        if !executable(a:1)
            echohl ErrorMsg
            echo printf("command %s is not executable", a:1)
            echohl None
            return
        endif
        if has('nvim')
            let cmd = a:000
        else
            let cmd = join(a:000)
        endif
        let res = systemlist(cmd)
    endif

    let winnr = -1
    for i in range(1, winnr('$'))
        if bufname(winbufnr(i)) ==# "ex_output"
            let winnr = i
        endif
    endfor
    if winnr == -1
        silent vertical split ex_output
    else
        execute winnr.."wincmd w"
    endif
    call meflib#basic#set_scratch(res)
    setlocal filetype=ex_output
    normal! gg
endfunction

