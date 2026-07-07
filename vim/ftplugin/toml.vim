scriptencoding utf-8

function! <SID>foldmethod(lnum) abort
    " :h fold-expr
    let line = getline(a:lnum)
    let nextline = getline(a:lnum+1)
    if line =~# '^\[\S*\]'
        " let cnt = count(line, '.')
        return '>1'
    elseif nextline =~# '^\[\S*\]'
        " let cnt = count(nextline, '.')
        return '<1'
    elseif match(line, '=') != -1
        return '='
    else
        return '0'
    endif
endfunction
setlocal foldmethod=expr
execute printf("setlocal foldexpr=%sfoldmethod(v:lnum)", expand("<SID>"))

