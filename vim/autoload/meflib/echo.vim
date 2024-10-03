
" main
function! meflib#echo#main(cmd, ...) abort
    let args = join(a:000, ' ')
    if a:cmd ==# 'pand'  " expandを打つのがめんどくさい
        echo expand(args)
    elseif a:cmd ==# 'env'  " 環境変数を見やすくする
        if a:0 > 0
            call meflib#echo#env(eval(args))
        endif
    elseif a:cmd ==# 'runtime'  " runtime 確認
        call meflib#echo#runtimepath()
    elseif a:cmd ==# 'conv'  " n進数に変換
        if a:0 > 0
            let args2 = join(a:000[1:], ' ')
            if (match(['10', '8', '16', '2'], a:1) != -1) && !empty(args2)
                call meflib#echo#convert(str2nr(a:1), args2)
            endif
        endif
    elseif a:cmd ==# 'time'  " time stamp <-> 時刻文字列変換
        if a:0 > 0
            call meflib#echo#time(eval(args))
        endif
    elseif a:cmd ==# 'color'  " 指定した色を表示
        if a:0 > 0
            call meflib#echo#color(args)
        endif
    endif
endfunction

" echo 拡張の補完 {{{
function! meflib#echo#comp(arglead, cmdline, cursorpos) abort
    let comp_list = split('pand env runtime conv time color')
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
            elseif cmdlines[1] == 'conv'
                return ['2', '8', '10', '16']
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

""" r, g, b / #RRGGBB がどんな色かを確認 {{{
function! meflib#echo#color(color_id) abort
    let is_gui = has('gui_running') || (has('termguicolors') && &termguicolors)
    if a:color_id =~# '^#[0-f][0-f][0-f][0-f][0-f][0-f]$'
        if !is_gui
            echo "GUI is not supported! Please check 'echo has(\"gui_running\")' and 'set termguicolors'"
            return
        endif
        execute printf('highlight TmpEchoHl gui=None guibg=%s guifg=None', a:color_id)
    elseif a:color_id =~# '^[0-5],\s*[0-5],\s*[0-5]$'
        let instr = substitute(a:color_id, '\s', '', 'g')
        let [r, g, b] = split(instr, ',')
        let hlterm = meflib#color#get_colorid(
                    \ str2nr(r), str2nr(g), str2nr(b), is_gui)
        if is_gui
            let term = 'gui'
        else
            let term = 'cterm'
        endif
            execute printf('highlight TmpEchoHl %s=None %sbg=%s %sfg=None',
                        \ term, term, hlterm, term)
    else
        echo 'Incorrect input. Available input are "#RRGGBB" or "r, g, b"'
        echo '00 <= RR, GG, BB <= ff / 0 <= r, g, b <= 5'
        return
    endif
    echo printf('input: %s |', a:color_id)
    echohl TmpEchoHl
    echon '   '
    echohl None
    echon '|'
endfunction
" }}}

