scriptencoding utf-8

" 複数行で順に加算／減算 {{{
function! meflib#ctrlax#addsub(ax, decrease) abort range
    let st = getpos('v')
    let end = getpos('.')
    " echomsg getpos('.')
    " echomsg getpos('v')
    let firstline = st[1]
    let lastline = end[1]
    let col = end[2]
    if a:ax ==# 'a'
        let cmd = "\<c-a>"
    else
        let cmd = "\<c-x>"
    endif
    " echo firstline
    " echo lastline
    for lnum in range(firstline, lastline)
        if a:decrease
            let num = lastline-lnum+1
        else
            let num = lnum-firstline+1
        endif
        " echo num
        call cursor(lnum, col)
        execute printf("normal! %d%s", num, cmd)
    endfor
    call cursor(st[1:])
endfunction
" }}}

" <c-a> でtrue/falseも置換したい {{{
function! meflib#ctrlax#true_false(premap) abort
    let cword = expand('<cword>')
    let pos = getpos('.')
    if cword ==# 'true'
        let new_word = 'false'
    elseif cword ==# 'false'
        let new_word = 'true'
    elseif cword ==# 'True'
        let new_word = 'False'
    elseif cword ==# 'False'
        let new_word = 'True'
    elseif cword ==# 'TRUE'
        let new_word = 'FALSE'
    elseif cword ==# 'FALSE'
        let new_word = 'TRUE'
    else
        let cnt = v:count1
        if a:premap ==# 'a'
            execute printf("normal! %d\<c-a>", cnt)
            try
                call repeat#set("\<c-a>")
            catch
                " do nothing.
            endtry
        elseif a:premap ==# "x"
            execute printf("normal! %d\<c-x>", cnt)
            try
                call repeat#set("\<c-x>")
            catch
                " do nothing.
            endtry
        endif
        return
    endif
    let pos = getpos('.')
    let col = pos[2]-len(cword)
    let cur_line = getline('.')
    if col >= 2
        " replace Nth true/false
        let new_line = cur_line[:col-2]
        let new_line .= substitute(cur_line[col-1:], cword, new_word, '')
    else
        " replace first true/false
        let new_line = substitute(cur_line, cword, new_word, '')
    endif
    delete _
    call append(pos[1]-1, new_line)
    call setpos('.', pos)
    try
        call repeat#set(printf("\<Cmd>call meflib#ctrlax#true_false('%s')\<CR>", a:premap))
    catch
        " do nothing.
    endtry
    call setpos('.', pos)
endfunction
" }}}

