
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
function! <SID>matchup_his() abort
    if &background == 'dark'
        highlight MatchWord ctermfg=None ctermbg=233 guifg=NONE guibg=#003030
    else
        highlight MatchWord ctermfg=None ctermbg=253 guifg=NONE guibg=#dadaff
    endif
endfunction
call meflib#add('plugin_his', expand('<SID>').'matchup_his')
" }}}

" 色々な言語のtemplate
Plug 'mattn/vim-sonictemplate', PlugCond(1, {'on': 'Template'})

