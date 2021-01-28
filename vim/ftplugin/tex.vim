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

function! s:replace_words()
    let l = line('.')
    let c = virtcol('.')
    %s/、/，/ge
    %s/。/．/ge
    " go back
    execute l
    execute "normal! ".c."|"
endfunction
autocmd texvim InsertLeave *.tex call s:replace_words()

" とりあえずコピー() from https://vim-jp.org/vimdoc-ja/quickfix.html#errorformat-LaTeX
set makeprg=latex\ \\\\nonstopmode\ \\\\input\\{$*}
set errorformat=%E!\ LaTeX\ %trror:\ %m,
            \%E!\ %m,
            \%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#,
            \%+W%.%#\ at\ lines\ %l--%*\\d,
            \%WLaTeX\ %.%#Warning:\ %m,
            \%Cl.%l\ %m,
            \%+C\ \ %m.,
            \%+C%.%#-%.%#,
            \%+C%.%#[]%.%#,
            \%+C[]%.%#,
            \%+C%.%#%[{}\\]%.%#,
            \%+C<%.%#>%.%#,
            \%C\ \ %m,
            \%-GSee\ the\ LaTeX%m,
            \%-GType\ \ H\ <return>%m,
            \%-G\ ...%.%#,
            \%-G%.%#\ (C)\ %.%#,
            \%-G(see\ the\ transcript%.%#),
            \%-G%*\\s,
            \%+O(%f)%r,
            \%+P(%f%r,
            \%+P\ %\\=(%f%r,
            \%+P%*[^()](%f%r,
            \%+P[%\\d%[^()]%#(%f%r,
            \%+Q)%r,
            \%+Q%*[^()])%r,
            \%+Q[%\\d%*[^()])%r

