" vim script encoding setting
scriptencoding utf-8
"" simple commands and short functions

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
" expandを打つのがめんどくさい {{{
command! -nargs=1 Echopand echo expand(<f-args>)
" }}}
" ipython を呼ぶ用 {{{
let s:ipythons = {'ipython':'Ipython', 'ipython2':'Ipython2', 'ipython3':'Ipython3'}
let s:ipy_ac = 1
for s:ipy in keys(s:ipythons)
    if executable(s:ipy)
        if has('nvim')
            execute printf('command! %s botright new | setlocal nonumber | terminal %s', s:ipythons[s:ipy], s:ipy)
            if s:ipy_ac
                autocmd cmdLocal TermOpen *ipython* startinsert
                let s:ipy_ac = 0
            endif
        else
            execute printf('command! %s botright terminal %s', s:ipythons[s:ipy], s:ipy)
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
" 開いているfile一覧 {{{
nnoremap <silent> <leader>l <Cmd>call meflib#tools#file_list()<CR>
" }}}
" termonal commandを快適に使えるようにする {{{
command! -nargs=? -complete=customlist,meflib#tools#term_comp  Terminal call meflib#tools#Terminal(<f-args>)
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
