
" echo 拡張の補完 {{{
function! meflib#echo#comp(arglead, cmdline, cursorpos) abort
    let comp_list = ['pand', 'env', 'runtime', 'conv10', 'conv8', 'conv2', 'conv16']
    let opt_num = len(split(a:cmdline, ' '))
    if opt_num == 1
        " :Echo <tab>
        return filter(comp_list, '!stridx(v:val, tolower(a:arglead))')
    elseif opt_num == 2
        if !empty(a:arglead)
            " :Echo p<tab>
            return filter(comp_list, '!stridx(v:val, tolower(a:arglead))')
        else
            " :Echo pand <tab>
        endif
    endif
    return []
endfunction
" }}}

" runtimepath check {{{
function! meflib#echo#runtimepath() abort
    for rp in split(copy(&runtimepath), ',', 'g')
        if !isdirectory(rp)
            echohl ErrorMsg
        endif
        echo rp
        echohl None
    endfor
endfunction
" }}}

" 環境変数を見やすくする {{{
function! meflib#echo#env(env) abort
    if match(a:env, ':') != -1
        let sep = ':'
    elseif match(a:env, ',') != -1
        let sep = ','
    else
        echo a:env
        return
    endif

    for e in split(a:env, sep)
        echo e
    endfor
endfunction
" }}}

" 進数変換 {{{
function! meflib#echo#convert(base, nr) abort
    let nr = eval(a:nr)
    if a:base == 10
        echo printf('%d', nr)
    elseif a:base == 8
        echo printf('%o', nr)
    elseif a:base == 16
        echo printf('%x', nr)
    elseif a:base == 2
        echo printf('%b', nr)
    endif
endfunction
" }}}

