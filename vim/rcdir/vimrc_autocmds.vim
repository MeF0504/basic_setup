" vim script encoding setting
scriptencoding utf-8
"" vim auto command settings

"vimrcを再読込する際にautocmdが重複しないようにautocmdをすべて解除
let s:echo_auto = 0
augroup local
    autocmd!
    if s:echo_auto == 1
        " {{{
        " autocmdを表示
        let s:autocmd_events = ['VimEnter',
                    \ 'FileReadPre *',
                    \ 'FileReadPost *',
                    \ 'BufRead *',
                    \ 'BufReadPre *',
                    \ 'BufReadPost *',
                    \ 'BufEnter *',
                    \ 'BufWinEnter *',
                    \ 'BufAdd *',
                    \ 'BufCreate *',
                    \ 'BufLeave *',
                    \ 'BufDelete *',
                    \ 'BufNew *',
                    \ 'Bufunload *',
                    \ 'BufHidden *',
                    \ 'FileType *',
                    \ 'Syntax *',
                    \ 'ColorScheme *',
                    \ 'WinNew *',
                    \ 'WinEnter *',
                    \ 'WinLeave *',
                    \ 'TabNew *',
                    \ 'TabEnter *',
                    \ 'TabLeave *',
                    \ 'InsertEnter *',
                    \ 'InsertLeave *',
                    \ 'InsertLeavePre *',
                    \ 'QuitPre *',
                    \ 'DirChanged *',
                    \ 'CmdWinEnter *',
                    \ 'CmdWinLeave *',
                    \ 'CmdlineEnter *',
                    \ 'CmdlineLeave *',
                    \ ]
        for s:ae in s:autocmd_events
            execute 'autocmd ' . s:ae . ' echomsg "'.s:ae . '" | sleep 300ms'
        endfor
        " }}}
    endif
augroup END

autocmd local BufEnter * let b:no_match_paren = 1   " tentative? because of paren error (Highlight_matching_Pair()).

" remove tags information when open new tab.
if exists("*settagstack")
    autocmd local TabNew * call settagstack(winnr(), {'length':0, 'curidx':1, 'items':[]})
endif

" toml fileのfiletypeをtomlにする
autocmd local BufEnter *.toml set filetype=toml

"vimgrepした際に新規windowで開くようにする
autocmd local QuickFixCmdPost *grep* cwindow

"quick fix windowでc-tで新しいtabで開く
autocmd local Filetype qf nnoremap <buffer><silent> <c-t> <c-w><s-t><CR>:cclose<CR>

" .mine系ファイルのtype設定
autocmd local BufEnter *bashrc* set filetype=sh
autocmd local BufEnter *zshrc* set filetype=zsh

" Neovimでterminalに入ったときにstartinsertする {{{
if has('nvim')
    let s:term_on = {}
    function! <SID>Term_pre() abort
        let res = ""
        if mode() == 't'
            let s:term_on[win_getid()] = 1
            " stopinsert
            let res = "\<C-\>\<C-n>"
        elseif expand('%')[:6] == 'term://'
            let s:term_on[win_getid()] = 0
        endif
        return res
    endfunction

    nnoremap <expr> g<Right>    <SID>Term_pre().'gt'
    nnoremap <expr> g<Left>     <SID>Term_pre().'gT'
    nnoremap <expr> s<Up>       <SID>Term_pre().'<C-w>k'
    nnoremap <expr> s<Down>     <SID>Term_pre().'<C-w>j'
    nnoremap <expr> s<Right>    <SID>Term_pre().'<C-w>l'
    nnoremap <expr> s<Left>     <SID>Term_pre().'<C-w>h'
    tnoremap <expr> g<Right>    <SID>Term_pre().'gt'
    tnoremap <expr> g<Left>     <SID>Term_pre().'gT'
    tnoremap <expr> s<Up>       <SID>Term_pre().'<C-w>k'
    tnoremap <expr> s<Down>     <SID>Term_pre().'<C-w>j'
    tnoremap <expr> s<Right>    <SID>Term_pre().'<C-w>l'
    tnoremap <expr> s<Left>     <SID>Term_pre().'<C-w>h'
    autocmd local BufEnter term://* if has_key(s:term_on, win_getid()) && (s:term_on[win_getid()]==1) | startinsert | endif
endif
" }}}

"autocmd local Filetype qf setlocal stl=%t%{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%l/%L\ %P
"See $VIMRUNTIME/ftplugin/qf.vim to change quickfix window statusline

" st_showmode != 0 なら(statuslineに表示されるので) showmode をoffにする
autocmd local VimEnter * ++once if llib#get_local_var('st_showmode', 1)!=0 | set noshowmode | endif

" Insertを抜けるときに日本語入力をoff {{{
if !exists('$SSH_CONNECTION') && llib#get_local_var('auto_ime_off', 0)==1   " ※ssh先ではhostのを変えるので意味なし
    if has('win32')
        autocmd local InsertLeave * set iminsert=0
    elseif has('mac')
            " 参考：https://rcmdnk.com/blog/2017/03/10/computer-mac-vim/
        if has('nvim')
            " nvimはjob_startが無い？っぽいのでとりあえず昔の方法で
            let s:imeoff = 'osascript -e "tell application \"System Events\" to key code 102"'
            autocmd local InsertLeave * call system(s:imeoff)
        else
            " 参考2: https://moyapro.com/2019/04/14/disable-ime-on-mac-vim/
            " 非同期で動かせるらしい
            autocmd local InsertLeave * call job_start(
                        \ ['osascript', '-e', 'tell application "System Events" to key code {102}'],
                        \ #{in_io: 'null', out_io: 'null', err_io: 'null'})
        endif
    endif
    set ttimeoutlen=1
endif
" }}}

