
" % key extender
Plug 'andymass/vim-matchup'
" {{{
" 既存plugin をoff
let g:loaded_matchit = 1
let g:loaded_matchparen = 1
let g:loaded_parenmatch = 1
" 画面外の対応はひとまず良いかな...
let g:matchup_matchparen_offscreen = {}
" highlights
function! <SID>matchup_his() abort
    if &background == 'dark'
        highlight MatchWord ctermfg=None ctermbg=233 guifg=NONE guibg=#003030
    else
        highlight MatchWord ctermfg=None ctermbg=253 guifg=NONE guibg=#dadaff
    endif
endfunction
call meflib#add('plugin_his', expand('<SID>').'matchup_his')

function! s:pcp_cb(adjs, wid, idx) abort
    if a:idx > 0
        normal! m'
        call cursor(a:adjs[a:idx-1], 1)
    endif
endfunction
function! s:print_current_pos()
    echohl Title | echon 'match-up-local:' | echohl None
    echon ' loading...'
    let trail = matchup#where#get(500)
    redraw!
    if empty(trail)
        echohl Title | echon 'match-up-local:' | echohl None
        echon ' no context found'
        return
    endif
    let last = -1
    let res = []
    let adjs = []
    for t in trail
        let opts = {
              \ 'noshowdir': 1,
              \ 'width': &columns - 1,
              \}
        let [str, adj] = matchup#matchparen#status_str(t[2], opts)
        if adj == last
            continue
        endif
        let pat = '\%(%\(<\)\|%#\(\w*\)#\)'
        let str = substitute(str, pat, '', 'g')
        call add(res, str)
        call add(adjs, adj)
        let last = adj
    endfor

    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines-&cmdheight-1,
                \ 'col': &numberwidth+&signcolumn+2,
                \ 'pos': 'botleft',
                \ 'nv_border': 'single',
                \ }

    call meflib#floating#select(res, config, function(expand('<SID>')..'pcp_cb', [adjs]))
endfunction
if exists('g:vscode')
    nnoremap <leader>c <Cmd>MatchupWhereAmI\?<CR>
else
    nnoremap <leader>c <Cmd>call <SID>print_current_pos()<CR>
endif
" }}}

" 色々な言語のtemplate
Plug 'mattn/vim-sonictemplate', PlugCond(1, {'on': 'Template'})
" {{{
let g:sonictemplate_vim_template_dir = meflib#basic#get_conf_dir()..'plug_conf/templates'
let g:sonictemplate_key = "\<c-q>a"
let g:sonictemplate_intelligent_key = "\<c-q>A"
" }}}

