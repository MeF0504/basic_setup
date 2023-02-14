
" main
function! meflib#echo#main(cmd, args='') abort
    if a:cmd ==# 'pand'  " expandを打つのがめんどくさい
        echo expand(a:args)
    elseif a:cmd ==# 'env'  " 環境変数を見やすくする
        if !empty(a:args)
            call meflib#echo#env(eval(a:args))
        endif
    elseif a:cmd ==# 'runtime'  " runtime 確認
        call meflib#echo#runtimepath()
    elseif a:cmd ==# 'conv10'  " 10進数に変換
        if !empty(a:args)
            call meflib#echo#convert(10, a:args)
        endif
    elseif a:cmd ==# 'conv8'  " 8進数に変換
        if !empty(a:args)
            call meflib#echo#convert(8, a:args)
        endif
    elseif a:cmd ==# 'conv16'  " 16進数に変換
        if !empty(a:args)
            call meflib#echo#convert(16, a:args)
        endif
    elseif a:cmd ==# 'conv2'  " 2進数に変換
        if !empty(a:args)
            call meflib#echo#convert(2, a:args)
        endif
    elseif a:cmd ==# 'time'  " 時刻表示
        if !empty(a:args)
            call meflib#echo#time(eval(a:args))
        endif
    endif
endfunction
" }}}

" echo 拡張の補完 {{{
function! meflib#echo#comp(arglead, cmdline, cursorpos) abort
    let comp_list = split('pand env runtime conv10 conv8 conv2 conv16 time')
    let cmdlines = split(a:cmdline, ' ')
    if len(cmdlines) == 1
        " :Echo <tab>
        return filter(comp_list, '!stridx(v:val, tolower(a:arglead))')
    elseif len(cmdlines) == 2
        if !empty(a:arglead)
            " :Echo p<tab>
            return filter(comp_list, '!stridx(v:val, tolower(a:arglead))')
        else
            " :Echo pand <tab>
            if cmdlines[1] == 'time'
                return [printf('%d', localtime())]
            endif
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

" str[pf]time {{{
function! meflib#echo#time(time) abort
    if type(a:time) == type(0)
        if exists('*strftime')
            echo strftime('%Y/%m/%d %H-%M-%S', a:time)
        else
            echo 'strftime is not supported.'
        endif
    elseif type(a:time) == type('')
        if exists('*strptime')
            if len(a:time) == 10
                echo strptime('%Y/%m/%d', a:time)
            elseif len(a:time) == 19
                echo strptime('%Y/%m/%d:%H-%M-%S', a:time)
            else
                echo 'format: "%Y/%m/%d" or "%Y-%m-%d:%H-&M-%S"'
            endif
        endif
    else
        echo 'incorrect format.'
    endif
endfunction
" }}}
