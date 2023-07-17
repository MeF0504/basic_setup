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

"autocmd local Filetype qf setlocal stl=%t%{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%l/%L\ %P
"See $VIMRUNTIME/ftplugin/qf.vim to change quickfix window statusline

" Insertを抜けるときに日本語入力をoff {{{
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

" 最後に閉じたtab, windowを保存しておく
autocmd local WinLeave * call meflib#set('last_file_win',
            \ [expand("%:p"), tabpagenr()])
autocmd local TabClosed * call meflib#set('last_file_tab',
            \ meflib#get('last_file_win', ['', '$']))
function! s:open_last_tab() abort
    let [tfile, tnum] = meflib#get('last_file_tab', ['', '$'])
    if empty(tfile)
        return
    endif
    if tnum =~ '[0-9]\+'
        let tnum -= 1
        if tnum > tabpagenr('$')
            let tnum = '$'
        endif
    endif
    execute printf('%stabnew %s', tnum, tfile)
endfunction
command! LastTab call <SID>open_last_tab()
command! LastWin execute "vsplit " . meflib#get('last_file_win', '')[0]

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
        let g:terminal_color_12 = term_cols[12]
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

" 色々と誤作動（というか余分なtab）が起きるっぽい
" autocmd local VimEnter * ++once call <SID>open_files_tab()

" file type毎のtags file 設定
autocmd local FileType * execute printf('setlocal tags^=.%s_tags;,./.%s_tags;', &filetype, &filetype)

" .<ft>_tags をtagsにする
autocmd local BufEnter .*_tags set filetype=tags

" markdownとgit commit messageでspell on
autocmd local Filetype markdown,gitcommit setlocal spell

" git status を表示
if meflib#get('show_git_status', 1)
    call meflib#git_status#main()
    autocmd local CursorMoved * call meflib#git_status#clear()
    autocmd local CursorHold * call meflib#git_status#main()
endif

" command line window
function! s:set_cmdwin() abort
    startinsert
endfunction
" これもmapしない分には消しておく
" autocmd local CmdWinEnter * call s:set_cmdwin()

