
let g:l_log_files = []

function! s:rm_log()
    for fy in g:l_log_files
        if filereadable(fy)
            call delete(fy)
        endif
    endfor
endfunction

function! LocalDebug(string) abort
    " set log file to operating list
    let l:logfile = expand("%:h") . "/log_buffer"
    if match(g:l_log_files, l:logfile) == -1
        let g:l_log_files += [l:logfile]
    endif

    " write log
    redir! >> %:h/log_buffer
    silent echo a:string
    silent echo ""
    redir end

    " set auto command that remove log file(s) when vim closed.
    autocmd local VimLeavePre * call s:rm_log()

    " open log file
    let l:winnum = bufwinnr(l:logfile)
    if l:winnum != -1
        if l:winnum == bufnr('%')
            close
        else
            let curbufnr = bufnr('%')
            exe winnum . 'wincmd w'
            close
            let winnum = bufwinnr(curbufnr)
            if winnr() != winnum
                exe winnum . 'wincmd w'
            endif
        endif
    endif
    execute "botright vertical split " . l:logfile
    wincmd p

endfunction

