
" % key extender
Plug 'andymass/vim-matchup'
" {{{
" 既存plugin をoff
let g:loaded_matchit = 1
let g:loaded_matchparen = 1
let g:loaded_parenmatch = 1
" 画面外の対応はひとまず良いかな...
let g:matchup_matchparen_offscreen = {}
nnoremap <leader>c <Cmd>MatchupWhereAmI\?<CR>
" highlights
if &background == 'dark'
    call meflib#set('plugin_his', {'ctermbg':233, 'guibg':'#003030'}, 'MatchWord')
else
    call meflib#set('plugin_his', {'ctermbg':253, 'guibg':'#dadaff'}, 'MatchWord')
endif
" }}}

" 色々な言語のtemplate
Plug 'mattn/vim-sonictemplate', PlugCond(1, {'on': 'Template'})

