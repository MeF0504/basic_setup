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
autocmd local Filetype qf nnoremap <buffer><silent> <c-t> <c-w><s-t><CR><Cmd>cclose<CR>

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
    function! s:Term_enter(tid) abort
        " to avoid working 'startinsert' in non-terminal window.
        if has_key(s:term_on, win_getid()) && (s:term_on[win_getid()]==1)
            startinsert
        endif
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
    autocmd local BufEnter term://* call timer_start(100, expand('<SID>')..'Term_enter')
endif
" }}}

" Insertを抜けるときに日本語入力をoff {{{
" DOC OPTIONS auto_ime_off
" If set to 1, turn off IME or Japanese input when leaving insert mode.
" DOCEND
if !exists('$SSH_CONNECTION') && meflib#get('auto_ime_off', 0)==1   " ※ssh先ではhostのを変えるので意味なし
    if has('win32') || has('win64')
        autocmd local InsertLeave * set iminsert=0
    elseif has('mac')
        " 参考：https://rcmdnk.com/blog/2017/03/10/computer-mac-vim/
        let s:imeoff = ['osascript', '-e', 'tell application "System Events" to key code {102}']
        if has('nvim')
            " nvimはjob_startが無い？っぽいのでとりあえず昔の方法で → jobstartで
            " let s:imeoff = 'osascript -e "tell application \"System Events\" to key code 102"'
            " autocmd local InsertLeave * call system(s:imeoff)
            autocmd local InsertLeave * call jobstart(
                        \ s:imeoff,
                        \ {'stdin': 'null', 'stderr_buffered': v:false, 'stdout_buffered': v:false})
        else
            " 参考2: https://moyapro.com/2019/04/14/disable-ime-on-mac-vim/
            " 非同期で動かせるらしい
            autocmd local InsertLeave * call job_start(
                        \ s:imeoff,
                        \ #{in_io: 'null', out_io: 'null', err_io: 'null'})
        endif
    endif
    set ttimeoutlen=1
endif
" }}}

" 最後に閉じたtab, windowを保存しておく {{{
" DOC OPTIONS last_file_win
" file name and tab number of last closed window.
" DOCEND
" DOC OPTIONS last_file_tab
" file name and tab number of last closed tab.
" DOCEND
autocmd local WinLeave * call meflib#set('last_file_win',
            \ [expand("%:p"), tabpagenr()])
autocmd local TabClosed * call meflib#set('last_file_tab',
            \ meflib#get('last_file_win', ['', '$']))
" }}}

" toml fileのfiletypeをtomlにする {{{
if !has('patch-8.2.2106')
    autocmd local BufEnter *.toml set filetype=toml
endif
" }}}

" 起動時に複数開いていたらtabで開く {{{
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

" 色々と誤作動（というか余分なtab）が起きるっぽい
" autocmd local VimEnter * ++once call <SID>open_files_tab()
" }}}

" file type毎のtags file 設定
autocmd local FileType * execute printf('setlocal tags^=.tagdir/%s_tags;,./.tagdir/%s_tags;', &filetype, &filetype)

" <ft>_tags をtagsにする
autocmd local BufEnter *_tags set filetype=tags

" markdownとgit commit messageでspell on
autocmd local Filetype markdown,gitcommit,tex setlocal spell

" git status を表示 {{{
" DOC OPTIONS show_git_status
" Flag to show git status on the window.
" DOCEND
if meflib#get('show_git_status', 1) && has('python3')  " git_status use Python.
    autocmd local CursorMoved * call meflib#git_status#clear()
    autocmd local CursorHold * call meflib#git_status#main()
    autocmd local DirChanged global call meflib#git_status#clear() |
                \ call meflib#git_status#update_info() |
                \ call meflib#git_status#main()
endif
" }}}

" command line window {{{
function! s:set_cmdwin() abort
    startinsert
endfunction
" これもmapしない分には消しておく
" autocmd local CmdWinEnter * call s:set_cmdwin()
" }}}

