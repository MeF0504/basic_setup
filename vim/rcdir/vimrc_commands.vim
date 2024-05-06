" vim script encoding setting
scriptencoding utf-8
"" simple commands and aliases

augroup cmdLocal
    autocmd!
augroup END

" {{{ 複数のコマンドで使われる設定
call meflib#set('exclude_dirs', ['.git', '.svn',
            \ '.mypy_cache', '.ipynb_checkpoints', '.pytest_cache',
            \ '.tagdir',
            \ ])
" }}}

" map leader にmapされているmapを表示 {{{
" nnoremap <Leader><Leader> :map mapleader<CR>
function! <SID>leader_map()
    map <Leader>
endfunction
nnoremap <silent> <Leader><Leader> <Cmd>call <SID>leader_map()<CR>
" }}}
" diff系command {{{
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
command! -nargs=1 -complete=file Diff vertical diffsplit <args>
"}}}
" conflict commentを検索 {{{
command! SearchConf /<<<<<<<\|=======\|>>>>>>>
" }}}
" ipython を呼ぶ用 {{{
let s:ipythons = {'ipython':'Ipython', 'ipython2':'Ipython2', 'ipython3':'Ipython3'}
let s:ipy_ac = 1
for [s:sh_cmd, s:vim_cmd] in items(s:ipythons)
    if executable(s:sh_cmd)
        if has('nvim')
            execute printf('command! %s botright <mods> new | setlocal nonumber | terminal %s', s:vim_cmd, s:sh_cmd)
            if s:ipy_ac
                autocmd cmdLocal TermOpen *ipython* startinsert
                let s:ipy_ac = 0
            endif
        else
            execute printf('command! %s botright <mods> terminal %s', s:vim_cmd, s:sh_cmd)
        endif
    endif
endfor
" }}}
" Spell check {{{
command! Spell if &spell!=1 | setlocal spell | echo 'spell: on' | else | setlocal nospell | echo 'spell: off' | endif
" }}}
" 要らない？user関数を消す {{{
function! s:del_comds()
    let del_commands = meflib#get('del_commands', [])
    for dc in del_commands
        if exists(':'.dc) == 2
            execute 'delcommand '.dc
        endif
    endfor
endfunction
if v:vim_did_enter
    call s:del_comds()
else
    autocmd cmdLocal VimEnter * ++once call s:del_comds()
endif
" }}}
" 開いているファイル情報を表示（ざっくり）{{{
command! FileInfo call meflib#fileinfo#main()
" }}}
" 辞書（というか英辞郎）で検索 {{{
command! -nargs=1 EijiroWeb call meflib#tools#eijiro(<f-args>)
" }}}
" ctags command {{{
command! -nargs=? -complete=dir Ctags call meflib#tools#exec_ctags(<f-args>)
" }}}
" job status check {{{
command! JobStatus call meflib#tools#chk_job_status()
" }}}
"vimでbinary fileを閲覧，編集 "{{{
command! BinMode call meflib#tools#BinaryMode()
" }}}
" termonal commandを快適に使えるようにする {{{
command! -nargs=? -complete=customlist,meflib#terminal#comp  Terminal call meflib#terminal#main(<q-mods>, <f-args>)
" }}}
" ファイルの存在チェック {{{
nnoremap <leader>f <Cmd>call meflib#filejump#main()<CR>
" }}}
" 行単位で差分を取る {{{
command! -nargs=+ -complete=file DiffLine call meflib#diffline#main(<f-args>)
" }}}
" 自作grep {{{
command! -nargs=? -complete=customlist,meflib#grep#comp Gregrep call meflib#grep#main(<f-args>)
" }}}
" XPM test function {{{
command! XPMLoader call meflib#tools#xpm_loader()
" }}}
" meflib#set された変数を表示 {{{
command! -bang -nargs=? -complete=customlist,meflib#basic#var_comp MefShowVar call meflib#basic#show_var("<bang>", <f-args>)
" }}}
" echo 拡張 {{{
command! -nargs=+ -complete=customlist,meflib#echo#comp Echo call meflib#echo#main(<f-args>)
" }}}
" 複数行で順に加算／減算 {{{
vnoremap <c-a><c-a> <Cmd>call meflib#ctrlax#addsub('a', 0)<CR>
vnoremap <c-a><c-x> <Cmd>call meflib#ctrlax#addsub('a', 1)<CR>
vnoremap <c-x><c-a> <Cmd>call meflib#ctrlax#addsub('x', 1)<CR>
vnoremap <c-x><c-x> <Cmd>call meflib#ctrlax#addsub('x', 0)<CR>
" }}}
" buffer を選んでtabで開く {{{
command! -bang BufOpen call meflib#openbuffer#main(<q-mods>, "<bang>")
" }}}
" Buffer にコマンドの出力結果をだす {{{
command! -nargs=* -complete=customlist,meflib#cmdout#cmp CmdOut call meflib#cmdout#main(<f-args>)
" }}}
" Jで\を消す {{{
nnoremap J <Cmd>call meflib#join_wrapper#main()<CR>
vnoremap J <Cmd>call meflib#join_wrapper#main()<CR>
" }}}
" <c-a> でtrue/falseも置換したい {{{
nnoremap <c-a> <Cmd>call meflib#ctrlax#true_false('a')<CR>
nnoremap <c-x> <Cmd>call meflib#ctrlax#true_false('x')<CR>
" }}}
" 関数一覧 {{{
command! -nargs=? -complete=customlist,meflib#tag_func_all#comp TagFuncAll call meflib#tag_func_all#open(<f-args>)
" }}}
" quick fix list {{{
call meflib#set('map_cmds', 'Qcmds', {
            \ 'f': "call meflib#qflist#main()"
            \ })
nnoremap <leader>q <Cmd>call meflib#basic#map_util('Qcmds')<CR>
" }}}
" ちょっとpython scriptをvimで動かしたいとき {{{
command! PyTmp call meflib#pytmp#main()
" }}}

