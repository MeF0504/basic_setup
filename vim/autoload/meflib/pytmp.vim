scriptencoding utf-8

" ちょっとpython scriptをvimで動かしたいとき
function! meflib#pytmp#main() abort
    if !has('python3')
        echoerr 'python3 is not supported.'
        return
    endif
    vertical new PyTmp
    call meflib#basic#set_scratch('# write the python script here!')
    setlocal filetype=python
    setlocal modifiable
    startinsert
    augroup PyTmp
        autocmd!
        autocmd InsertLeave <buffer> call s:run_python()
    augroup END
endfunction

function! s:run_python() abort
    let failed = v:false
    for ln in getline(1, line('$'))
        if ln =~# "^#"
            continue
        endif
        if len(ln) == 0
            continue
        endif
        try
            execute printf("python3 %s", ln)
        catch
            echomsg printf("pytmp: failed to run %s", ln)
            let failed = v:true
            break
        endtry
    endfor
    if !failed
        quit
    endif
endfunction
