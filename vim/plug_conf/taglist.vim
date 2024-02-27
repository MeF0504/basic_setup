" 関数一覧を表示
" repo = 'vim-scripts/taglist.vim'
PlugWrapper 'yegappan/taglist', PlugCond(1, {'on': 'TlistToggle'})
let g:Tlist_Exit_OnlyWindow = 1
let g:Tlist_Show_One_File = 1
let g:Tlist_File_Fold_Auto_Close = 1
" 幅の設定
" gui offのときは自動で幅が変わらないようにする (バグる)
if has('gui_running')
    let s:Max_WinWidth = 45
    let g:Tlist_Inc_Winwidth = 1
else
    let s:Max_WinWidth = 35
    let g:Tlist_Inc_Winwidth = 0
endif
function! s:taglist_his()
    highlight MyTagListTagName cterm=None ctermfg=0 ctermbg=111 gui=NONE guifg=#101010 guibg=#a0b5ff
endfunction
call meflib#add('plugin_his', expand('<SID>').'taglist_his')

function! <SID>Open_taglist() abort
    " {{{
    if exists('g:Tlist_Use_Right_Window')
        let l:tlist_right_old = g:Tlist_Use_Right_Window
    else
        let l:tlist_right_old = 0
    endif
    " guiの時はいらないかも？↓
    if winwidth(winnr()) > s:Max_WinWidth*3
        let g:Tlist_WinWidth = s:Max_WinWidth
    else
        let g:Tlist_WinWidth = (winwidth(winnr())/16)*5
    endif

    " 右端だと右側に開く
    if (winnr()==1 ) || (winnr() != winnr("1l"))
        let g:Tlist_Use_Right_Window = 0
    else
        let g:Tlist_Use_Right_Window = 1
    endif

    " 右側で表示して閉じた際にwinnrが変わる問題対応
    let winnr = -1
    if &filetype != 'taglist'
        let winnr = winnr()
        if getbufvar(tabpagebuflist()[0], '&filetype') == 'taglist'
            let winnr -= 1
        endif
    endif

    TlistToggle

    " when tablist is closed
    if (getbufvar(tabpagebuflist()[0], '&filetype') != 'taglist') &&
        \ (getbufvar(tabpagebuflist()[-1], '&filetype') != 'taglist')
        if winnr != -1
            execute winnr . 'wincmd w'
        endif
    endif
    let g:Tlist_Use_Right_Window = l:tlist_right_old
    " }}}
endfunction
" nnoremap <silent> <Leader>t <Cmd>call <SID>Open_taglist()<CR>

