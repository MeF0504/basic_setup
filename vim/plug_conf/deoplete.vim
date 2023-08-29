" Plug から見えるためにはg: で定義しないといけない
if meflib#get('plug_opt', 'deoplete', 0)
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
else
    call meflib#add('unload_plugins', 'Shougo/deoplete.nvim')
    call meflib#add('unload_plugins', 'Shougo/neco-syntax')
    call meflib#add('unload_plugins', 'Shougo/deoplete-clangx')
    call meflib#add('unload_plugins', 'deoplete-plugins/deoplete-jedi')
    call meflib#add('unload_plugins', 'deoplete-plugins/deoplete-zsh')
endif
" dark powered 補完plugin
PlugWrapper 'Shougo/deoplete.nvim', PlugCond(1, {'on':[]})
" syntax file から補完候補を作成
PlugWrapper 'Shougo/neco-syntax'
" c言語用補完 plugin
PlugWrapper 'Shougo/deoplete-clangx', PlugCond(1, {'for': 'c'})
" python 用補完 plugin
PlugWrapper 'deoplete-plugins/deoplete-jedi', PlugCond(1, {'for': 'python'})
" zsh 用補完 plugin
PlugWrapper 'deoplete-plugins/deoplete-zsh', PlugCond(1, {'for': 'zsh'})


