
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

    if has_key(l:opt, a:1)
        let l:env = l:opt[a:1]
    else
        call s:echo_help(l:opt)
        return
    endif

    call append(line("."), "\\end(" . l:env . ")")
    call append(line("."), "")
    call append(line("."), "\\begin(" . l:env . ")")
    normal! 2j

endfunction

command! -nargs=? AddEnv call Add_env(<q-args>)


