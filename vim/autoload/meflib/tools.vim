"vim script encording setting
set encoding=utf-8
scriptencoding utf-8

" vim (almost) self-made function file
" 50行を超えたら単一ファイルにする

" 辞書（というか英辞郎）で検索 {{{
function! meflib#tools#eijiro(word)
    let url = '"https://eowf.alc.co.jp/search?q='.a:word.'"'
    let web_cmd = meflib#basic#get_exe_cmd()
    if empty(web_cmd)
        echo printf('command to open the url %s is not found.', url)
        return
    endif
    call system(printf('%s %s', web_cmd, url))
endfunction
" }}}

" ctags command {{{
function! meflib#tools#exec_ctags(...) abort
    if !executable('ctags')
        echohl ErrorMsg
        echomsg 'ctags is not executable'
        echohl None
        return
    endif

    if a:0 == 0
        let cwd = meflib#basic#get_top_dir(expand('%:h'))
    else
        let cwd = a:1
    endif
    if !isdirectory(cwd)
        echohl ErrorMsg
        echomsg printf('"%s" is not a directory', cwd)
        echohl None
        return
    endif

    let ctags_opt = meflib#get('ctags_opt', '')
    let out_file_name = printf('%s/.%s_tags', cwd, &filetype)
    let ctags_out = '-f '..out_file_name
    if &filetype == 'cpp'
        let ft = 'c++'
    else
        let ft = &filetype
    endif
    let spec_ft = '--languages='..ft

    let ctags_cmd = printf('ctags %s %s %s -R %s', ctags_opt, ctags_out, spec_ft, cwd)
    call system(ctags_cmd)
    echomsg ctags_cmd
endfunction
" }}}

" job status check {{{
function! meflib#tools#chk_job_status() abort
    if has('job')
        let jobs = job_info()
        for idx in range(len(jobs))
            let job = jobs[idx]
            echo idx
            echon ' '
            echohl Type
            echon job_status(job)
            echohl None
            echon ' '
            echohl Statement
            echon job_info(job).cmd
            echohl None
        endfor
        let num = input('please select job to kill (empty cancel): ')
        if !empty(num) && num>=0 && num<len(jobs)
            if job_status(jobs[num]) == 'run'
                call job_stop(jobs[num])
            else
                call job_stop(jobs[num], 'kill')
            endif
        endif
    elseif has('nvim')
        for chan in nvim_list_chans()
            echo chan.id
            if has_key(chan, 'mode')
                echon ' '
                echohl Type
                echon chan.mode
                echohl None
            endif
            if has_key(chan, 'argv')
                echon ' '
                echohl Statement
                echon chan.argv
                echohl None
            endif
        endfor
    endif
endfunction
" }}}

"vimでbinary fileを閲覧，編集 "{{{
let s:bin_fts = ''
function! meflib#tools#BinaryMode()
    " :h using-xxd
    " vim -b : edit binary using xxd-format!
    let ext = '.'.expand('%:e')
    if ext == '.'
        let ext = expand('%:t')
    endif
    if match(split(s:bin_fts, ','), '*'.ext) != -1
        echo 'already set '.ext
        return
    endif
    let s:bin_fts .= '*'.ext.','
    augroup Binary
        autocmd!
        execute "autocmd BufReadPre   ".s:bin_fts." let &bin=1"
        execute "autocmd BufReadPost  ".s:bin_fts." if &bin | %!xxd"
        execute "autocmd BufReadPost  ".s:bin_fts." set ft=xxd | endif"
        execute "autocmd BufWritePre  ".s:bin_fts." if &bin | %!xxd -r"
        execute "autocmd BufWritePre  ".s:bin_fts." endif"
        execute "autocmd BufWritePost ".s:bin_fts." if &bin | %!xxd"
        execute "autocmd BufWritePost ".s:bin_fts." set nomod | endif"
    augroup END
    e!
endfunction
" }}}

" XPM test function {{{
function! meflib#tools#xpm_loader()
    let file = expand('%')
    if has('gui_running')
        let is_gui = 1
    else
        let is_gui = 0
    endif
    pythonx << EOL
import vim
from pymeflib.xpm_loader import XPMLoader

xpm_file = vim.eval('file')
is_gui = int(vim.eval('is_gui'))
if is_gui != 0: is_gui = True
else: is_gui = False

xpm = XPMLoader(xpm_file)
xpm.get_vim_setings(gui=is_gui)

for i,vim_setting in enumerate(xpm.vim_settings):
    hi = vim_setting['highlight']
    match = vim_setting['match']
    # print(hi)
    # print(match)
    vim.command(match)
    vim.command(hi)

# print(xpm.vim_finally)
vim.command(xpm.vim_finally)
EOL
endfunction
" }}}

" 複数行で順に加算／減算 {{{
function! meflib#tools#addsub(ax, decrease) abort range
    let st = getpos('v')
    let end = getpos('.')
    " echomsg getpos('.')
    " echomsg getpos('v')
    let firstline = st[1]
    let lastline = end[1]
    let col = end[2]
    if a:ax ==# 'a'
        let cmd = "\<c-a>"
    else
        let cmd = "\<c-x>"
    endif
    " echo firstline
    " echo lastline
    for lnum in range(firstline, lastline)
        if a:decrease
            let num = lastline-lnum+1
        else
            let num = lnum-firstline+1
        endif
        " echo num
        call cursor(lnum, col)
        execute printf("normal! %d%s", num, cmd)
    endfor
    call cursor(st[1:])
endfunction
" }}}

" Jで\を消す {{{
function! meflib#tools#join_wrapper() abort
    " https://zenn.dev/kawarimidoll/articles/7ae1e7a485d882
    let from = line('v')
    let to = line('.')
    if from == to
        let to += 1
    endif
    " echomsg from..' - '..to
    let pattern = ''
    let sla = ''
    if match(getline(from, to), '^.*\\s*$') != -1
        " ends with \
        let sla = 'end'
        let pattern = '/^.*\zs\\s*//'
    elseif match(getline(from, to), '^\s*\\s*.*$') != -1
        " starts with \
        let sla = 'start'
        let pattern = '/^\s*\\s*//'
    endif
    " echomsg 'sla='..sla

    if mode() ==# 'n'
        if sla ==# 'end'
            let range = from
        elseif sla ==# 'start'
            let range = from+1
        else
            " sla is empty => pattern is empty. do not used.
        endif
    else
        if sla ==# 'end'
            let range = printf('%s,%s', from, to-1)
        elseif sla ==# 'start'
            let range = printf('%s,%s', from+1, to)
        else
            " sla is empty => pattern is empty. do not used.
        endif
    endif
    if !empty(pattern)
        execute printf('silent! %ssubstitute%s', range, pattern)
    endif

    if mode() ==# 'n'
        execute printf('keepjump normal! %sGJ', from)
    else
        " already selected.
        normal! J
    endif
endfunction
" }}}

