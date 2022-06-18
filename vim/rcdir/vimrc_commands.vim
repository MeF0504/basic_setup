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
for s:ipy in keys(s:ipythons)
    if executable(s:ipy)
        if has('nvim')
            execute printf('command! %s botright new | setlocal nonumber | terminal %s', s:ipythons[s:ipy], s:ipy)
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
    let del_commands = meflib#get_local_var('del_commands', [])
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
let s:term_opts = ['win', 'term']
let s:term_win_opts = ['S', 'V', 'F', 'P']
function! s:complete_term(arglead, cmdline, cursorpos) abort
    ":h :command-completion-custom
    let arglead = tolower(a:arglead)
    let cmdline = tolower(a:cmdline)
    let opt_idx = strridx(cmdline, '-')
    let end_space_idx = strridx(cmdline, ' ')
    " return ['-1-'.a:arglead, '-2-'.a:cmdline, '-3-'.a:cursorpos, '-4-'.a:cmdline[opt_idx:]]
    if arglead[0] == '-'
        " select option
        let res = []
        for opt in s:term_opts
            let res += ['-'.opt]
        endfor
        return filter(res, '!stridx(tolower(v:val), arglead)')
    elseif cmdline[opt_idx:end_space_idx-1] == '-win'
        return s:term_win_opts
    elseif cmdline[opt_idx:end_space_idx-1] == '-term'
        if exists('*term_list')
            let term_names = filter(map(term_list(), 'bufname(v:val)'), '!stridx(tolower(v:val), arglead)')
        else
            if has('nvim')
                let st_idx = 6
                let term_head = 'term://'
            else
                let st_idx = 0
                let term_head = '!'
            endif
            let term_list = []
            for i in range(1, tabpagenr('$'))
                for j in tabpagebuflist(i)
                    let bname = bufname(j)
                    if bname[:st_idx] == term_head
                        let term_list += [bname]
                    endif
                endfor
            endfor
            let term_names = filter(term_list, '!stridx(tolower(v:val), arglead)')
        endif
        return term_names
    else
        " shell コマンド一覧が得られたら嬉しい
        " $PATHでfor文を回す手もあるが，時間が掛かりそう...
        return []
    endif
endfunction
command! -nargs=? -complete=customlist,s:complete_term  Terminal call meflib#tools#Terminal(<f-args>)
" }}}
" ファイルの存在チェック {{{
nnoremap <leader>f <Cmd>call meflib#tools#Jump_path()<CR>
" }}}
" 行単位で差分を取る {{{
command! -nargs=+ -complete=file DiffLine call meflib#tools#diff_line(<f-args>)
" }}}
" 自作grep {{{
function! <SID>grep_comp(arglead, cmdline, cursorpos) abort
    let arglead = tolower(a:arglead)
    let cmdline = tolower(a:cmdline)
    let cur_opt = split(cmdline, ' ', 1)[-1]
    if (match(cur_opt, '=') == -1)
        let opts = ['wd', 'dir', 'ex']
        return filter(map(opts, 'v:val."="'), '!stridx(tolower(v:val), arglead) && match(cmdline, v:val)==-1')
    elseif cur_opt =~ 'dir='
        let arg = split(cur_opt, '=', 1)[1]
        let files = split(glob(arg..'*'), '\n')
        return map(files+['opened'], "'dir='..v:val")
    else
        return []
    endif
endfunction

command! -nargs=? -complete=customlist,<SID>grep_comp Gregrep call meflib#tools#Mygrep(<f-args>)
command! -nargs=? -complete=customlist,<SID>grep_comp GREgrep Gregrep
" }}}
" XPM test function {{{
command! XPMLoader call meflib#tools#xpm_loader()
" }}}
