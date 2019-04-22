
function! Add_env(...)
    let l:opt = [
                \"document",
                \"equation",
                \"itemize",
                \"enumerate",
                \]

    if a:0 == "0"
        echo "enable options;"
        for i in range(len(l:opt))
            echo i . " : " . l:opt[i]
        endfor
        return
    endif

    if a:1 < len(l:opt)
        let l:env = l:opt[a:1]
    endif

    call append(line("."), "\\end(" . l:env . ")")
    call append(line("."), "")
    call append(line("."), "\\begin(" . l:env . ")")
    normal! 2j

endfunction

command! -nargs=? AddEnv call Add_env(<args>)


