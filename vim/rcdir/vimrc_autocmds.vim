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
                    \ 'FileReadPre',
                    \ 'FileReadPost',
                    \ 'BufRead',
                    \ 'BufReadPre',
                    \ 'BufReadPost',
                    \ 'BufEnter',
                    \ 'BufWinEnter',
                    \ 'BufAdd',
                    \ 'BufCreate',
                    \ 'BufLeave',
                    \ 'BufDelete',
                    \ 'BufNew',
                    \ 'Bufunload',
                    \ 'BufHidden',
                    \ 'FileType',
                    \ 'Syntax',
                    \ 'ColorScheme',
                    \ 'WinNew',
                    \ 'WinEnter',
                    \ 'WinLeave',
                    \ 'TabNew',
                    \ 'TabEnter',
                    \ 'TabLeave',
                    \ 'InsertEnter',
                    \ 'InsertLeave',
                    \ 'InsertLeavePre',
                    \ 'QuitPre',
                    \ 'DirChanged',
                    \ 'CmdWinEnter',
                    \ 'CmdWinLeave',
                    \ 'CmdlineEnter',
                    \ 'CmdlineLeave',
                    \ 'TerminalOpen',
                    \ ]
                    " \ 'SourcePre',
        for s:ae in s:autocmd_events
            if s:ae == 'TerminalOpen' && has('nvim')
                let s:ae = 'TermOpen'
            endif
            execute printf('autocmd %s * echomsg "%s "..expand("<amatch>") | sleep 300ms', s:ae, s:ae)
        endfor
        " }}}
    endif
augroup END

autocmd local BufEnter * let b:no_match_paren = 1   " tentative? because of paren error (Highlight_matching_Pair()).

" remove tags information when open new tab.
if exists("*settagstack")
    autocmd local TabNew * call settagstack(winnr(), {'length':0, 'curidx':1, 'items':[]})
endif

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
autocmd local VimEnter * ++once if meflib#get_local_var('st_showmode', 1)!=0 | set noshowmode | endif

" Insertを抜けるときに日本語入力をoff {{{
if !exists('$SSH_CONNECTION') && meflib#get_local_var('auto_ime_off', 0)==1   " ※ssh先ではhostのを変えるので意味なし
    if has('win32') || has('win64')
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

" 最後に閉じたtab, windowを保存しておく
autocmd local WinLeave * call meflib#set_local_var('last_file_win', expand("%:p"))
autocmd local TabClosed * call meflib#set_local_var('last_file_tab', meflib#get_local_var('last_file_win', ''))
command! LastTab execute "tabnew " . meflib#get_local_var('last_file_tab', '')
command! LastWin execute "vsplit " . meflib#get_local_var('last_file_win', '')

if !has('patch-8.2.2106')
    " toml fileのfiletypeをtomlにする
    autocmd local BufEnter *.toml set filetype=toml
endif

" terminalの色設定 (vimはoptionで)
if has('nvim')
    function! <SID>set_term_col() abort
        let term_cols = meflib#basic#get_term_color()
        let g:terminal_color_0 = term_cols[0]
        let g:terminal_color_1 = term_cols[1]
        let g:terminal_color_2 = term_cols[2]
        let g:terminal_color_3 = term_cols[3]
        let g:terminal_color_4 = term_cols[4]
        let g:terminal_color_5 = term_cols[5]
        let g:terminal_color_6 = term_cols[6]
        let g:terminal_color_7 = term_cols[7]
        let g:terminal_color_8 = term_cols[8]
        let g:terminal_color_9 = term_cols[9]
        let g:terminal_color_10 = term_cols[10]
        let g:terminal_color_11 = term_cols[11]
        let g:terminal_color_12 = term_cols[0]
        let g:terminal_color_13 = term_cols[13]
        let g:terminal_color_14 = term_cols[14]
        let g:terminal_color_15 = term_cols[15]
    endfunction
    autocmd local TermOpen * call <SID>set_term_col()
endif

" 起動時に複数開いていたらtabで開く
function! <SID>open_files_tab() abort
    if bufnr('$') == 1
        return
    endif
    for i in range(2, bufnr('$'))
        " 1はすでに開いているのでskip
        if buflisted(i)
            " echomsg i..': '..bufname(i)
            execute printf('tabnew %s', bufname(i))
        endif
    endfor
    normal! 1gt
endfunction

autocmd local VimEnter * ++once call <SID>open_files_tab()

" file type毎のtags file 設定
autocmd local FileType * execute printf('setlocal tags^=.%s_tags;', &filetype)

