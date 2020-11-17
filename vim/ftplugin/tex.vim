augroup texvim
    autocmd!
augroup END

" {{{ Add_env
function! Add_env(...)
    let l:opt = {
                \"doc":"document",
                \"eq":"equation",
                \"item":"itemize",
                \"enum":"enumerate",
                \}
    function! s:echo_help(opt)
        echo "enable options;"
        for i in keys(a:opt)
            echo i . " : " . a:opt[i]
        endfor
        return
    endfunction

    if a:0 == "0"
        call s:echo_help(l:opt)
        return
    endif

    let l:args = split(a:1)
    if len(l:args) == 0
        call s:echo_help(l:opt)
        return
    endif

    if has_key(l:opt, l:args[0])
        let l:env = l:opt[l:args[0]]
    else
        call s:echo_help(l:opt)
        return
    endif

    if len(l:args) > 1
        if l:args[1] == "as"
            let l:env .= "*"
        endif
    endif

    call append(line("."), "\\end{" . l:env . "}")
    call append(line("."), "")
    call append(line("."), "\\begin{" . l:env . "}")
    normal! 2j

endfunction

command! -nargs=? AddEnv call Add_env(<q-args>)
" }}}

set suffixesadd+=.tex

autocmd texvim InsertLeave *.tex %s/、/，/ge
autocmd texvim InsertLeave *.tex %s/。/．/ge

