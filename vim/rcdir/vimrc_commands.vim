" vim script encoding setting
scriptencoding utf-8
"" simple commands and aliases

augroup cmdLocal
    autocmd!
augroup END

 map leader にmapされているmapを表示 {{{
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
command! FileInfo call meflib#tools#fileinfo()
" }}}
" 辞書（というか英辞郎）で検索 {{{
command! -nargs=1 EijiroWeb call meflib#tools#eijiro(<f-args>)
" }}}
" ctags command {{{
command! -nargs=? Ctags call meflib#tools#exec_ctags(<f-args>)
" }}}
" job status check {{{
command! JobStatus call meflib#tools#chk_job_status()
" }}}
"vimでbinary fileを閲覧，編集 "{{{
command! BinMode call meflib#tools#BinaryMode()
" }}}
" termonal commandを快適に使えるようにする {{{
command! -nargs=? -complete=customlist,meflib#terminal#comp  Terminal call meflib#terminal#main(<f-args>)
" }}}
" ファイルの存在チェック {{{
nnoremap <leader>f <Cmd>call meflib#tools#Jump_path()<CR>
" }}}
" 行単位で差分を取る {{{
command! -nargs=+ -complete=file DiffLine call meflib#tools#diff_line(<f-args>)
" }}}
" 自作grep {{{
command! -nargs=? -complete=customlist,meflib#tools#grep_comp Gregrep call meflib#tools#Mygrep(<f-args>)
command! -nargs=? -complete=customlist,meflib#tools#grep_comp GREgrep Gregrep
" }}}
" XPM test function {{{
command! XPMLoader call meflib#tools#xpm_loader()
" }}}
" meflib#set された変数を表示 {{{
command! MefShowVar call meflib#get('', '')
" }}}
" echo 拡張 {{{
function! s:echo_ex(cmd, args='') abort
    if a:cmd ==# 'pand'  " expandを打つのがめんどくさい
        echo expand(a:args)
    elseif a:cmd ==# 'env'  " 環境変数を見やすくする
        if !empty(a:args)
            call meflib#echo#env(eval(a:args))
        endif
    elseif a:cmd ==# 'runtime'  " runtime 確認
        call meflib#echo#runtimepath()
    elseif a:cmd ==# 'conv10'  " 10進数に変換
        if !empty(a:args)
            call meflib#echo#convert(10, a:args)
        endif
    elseif a:cmd ==# 'conv8'  " 8進数に変換
        if !empty(a:args)
            call meflib#echo#convert(8, a:args)
        endif
    elseif a:cmd ==# 'conv16'  " 16進数に変換
        if !empty(a:args)
            call meflib#echo#convert(16, a:args)
        endif
    elseif a:cmd ==# 'conv2'  " 2進数に変換
        if !empty(a:args)
            call meflib#echo#convert(2, a:args)
        endif
    elseif a:cmd ==# 'time'  " 時刻表示
        if !empty(a:args)
            call meflib#echo#time(eval(a:args))
        endif
    endif
endfunction
command! -nargs=+ -complete=customlist,meflib#echo#comp Echo call s:echo_ex(<f-args>)
" }}}
" 複数行で順に加算／減算 {{{
vnoremap <c-a><c-a> <Cmd>call meflib#tools#addsub('a', 0)<CR>
vnoremap <c-a><c-x> <Cmd>call meflib#tools#addsub('a', 1)<CR>
vnoremap <c-x><c-a> <Cmd>call meflib#tools#addsub('x', 1)<CR>
vnoremap <c-x><c-x> <Cmd>call meflib#tools#addsub('x', 0)<CR>
" }}}
" buffer を選んでtabで開く {{{
command! -bang BufOpen call meflib#tools#open_buffer(<q-mods>, "<bang>")
" }}}
" Buffer にコマンドの出力結果をだす {{{
command! -nargs=* ExOut call meflib#tools#ex(<f-args>)
" }}}
