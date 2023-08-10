" Plug から見えるためにはg: で定義しないといけない
let g:l_deo = meflib#get('load_plugin', 'deoplete', 0)
" dark powered 補完plugin
Plug 'Shougo/deoplete.nvim', PlugCond(g:l_deo, {'on':[]})
if g:l_deo
    call meflib#add('insert_plugins', 'deoplete.nvim')
    let g:deoplete#enable_at_startup = 1
    inoremap <expr><tab> pumvisible() ? "\<C-n>" :
            \ neosnippet#expandable_or_jumpable() ?
            \    "\<Plug>(neosnippet_expand_or_jump)" : "\<tab>"
    inoremap <expr><S-tab> pumvisible() ? "\<C-p>" :
            \ neosnippet#expandable_or_jumpable() ?
            \    "\<Plug>(neosnippet_expand_or_jump)" : "\<S-tab>"

    "" test
    autocmd PlugLocal FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd PlugLocal FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd PlugLocal FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd PlugLocal FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd PlugLocal FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    " auto close preview window.
    autocmd PlugLocal CompleteDone * silent! pclose!
endif

" syntax file から補完候補を作成
Plug 'Shougo/neco-syntax', PlugCond(g:l_deo)
" c言語用補完 plugin
Plug 'Shougo/deoplete-clangx', PlugCond(g:l_deo, {'for': 'c'})
" python 用補完 plugin
Plug 'deoplete-plugins/deoplete-jedi', PlugCond(g:l_deo, {'for': 'python'})
" zsh 用補完 plugin
Plug 'deoplete-plugins/deoplete-zsh', PlugCond(g:l_deo, {'for': 'zsh'})
unlet g:l_deo


