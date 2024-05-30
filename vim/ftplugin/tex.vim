augroup texvimlocal
    autocmd!
augroup END

" $VIMRUNTIME/ftplugin あたりで上書きされてそうなのでautocmd化する
autocmd texvimlocal BufEnter *.tex setlocal suffixesadd+=.tex
autocmd texvimlocal BufEnter *.tex setlocal suffixesadd+=.bib
" tex fileでも<Enter>で改行時に自動コメントアウト
autocmd texvimlocal BufEnter *.tex setlocal formatoptions+=r

function! s:replace_words()
    let l = line('.')
    let c = virtcol('.')
    %s/、/，/ge
    %s/。/．/ge
    " go back
    execute l
    execute "normal! ".c."|"
endfunction
autocmd texvimlocal InsertLeave *.tex call s:replace_words()

function! <SID>foldmethod(lnum) abort
    let line = getline(a:lnum)
    if match(line, '^\s*\\begin{') != -1
        return 'a1'
    elseif match(line, '^\s*\\end{') != -1
        return 's1'
    else
        return '='
    endif
endfunction
setlocal foldmethod=expr
execute printf("setlocal foldexpr=%sfoldmethod(v:lnum)", expand("<SID>"))
normal! zR

" [[, ]]でchapter, sectionを探す
nnoremap <silent><buffer> [[ m':call search('^\s*\(\\chapter\\|\\\%[sub\%[sub]]section\)\>', "bW")<CR>
nnoremap <silent><buffer> ]] m':call search('^\s*\(\\chapter\\|\\\%[sub\%[sub]]section\)\>', "W")<CR>

" とりあえずコピー() from https://vim-jp.org/vimdoc-ja/quickfix.html#errorformat-LaTeX
setlocal makeprg=latex\ \\\\nonstopmode\ \\\\input\\{$*}
setlocal errorformat=%E!\ LaTeX\ %trror:\ %m,
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

