augroup texvim
    autocmd!
augroup END

" $VIMRUNTIME/ftplugin あたりで上書きされてそうなのでautocmd化する
autocmd texvim BufEnter *.tex set suffixesadd+=.tex
autocmd texvim BufEnter *.tex set suffixesadd+=.bib
" tex fileでも<Enter>で改行時に自動コメントアウト
autocmd texvim BufEnter *.tex set formatoptions+=r

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

