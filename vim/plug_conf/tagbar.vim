scriptencoding utf-8

PlugWrapper 'preservim/tagbar', PlugCond(1, {'on': 'TagbarToggle'})
let g:tagbar_width = meflib#get('side_width', 30)
let g:tagbar_autoclose = 0
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0
let g:tagbar_show_data_type = 1
let g:tagbar_show_tag_linenumbers = 1
let g:tagbar_use_cache = 1  " 必要に応じて確認

function! s:tagbar_his()
    highlight TagbarHighlight cterm=None ctermfg=0 ctermbg=111 gui=NONE guifg=#101010 guibg=#a0b5ff
endfunction
call meflib#add('plugin_his', expand('<SID>').'tagbar_his')

" sはwindow移動に使うのでSでsort
let g:tagbar_map_togglesort = 'S'

function! s:tagbar_toggle() abort
    " 右端だと右側に開く
    if (winnr()==1 ) || (winnr() != winnr("1l"))
        let g:tagbar_position = 'topleft vertical'
    else
        let g:tagbar_position = 'botright vertical'
    endif
    TagbarToggle
endfunction
nnoremap <silent> <Leader>t <Cmd>call <SID>tagbar_toggle()<CR>
call meflib#map_util#desc('n', 't', '関数／変数など一覧')
