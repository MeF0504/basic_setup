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
    let ctags_cmd = meflib#get('ctags_config', 'command', 'ctags')
    if !executable(ctags_cmd)
        echohl ErrorMsg
        echomsg printf('%s is not executable', ctags_cmd)
        echohl None
        return
    endif

    if a:0 == 0
        let cwd = meflib#basic#get_top_dir(expand('%:h'))
        if empty(cwd)
            let cwd = getcwd()
        endif
    else
        let cwd = fnamemodify(a:1, ':p')
    endif
    if !isdirectory(cwd)
        echohl ErrorMsg
        echomsg printf('"%s" is not a directory', cwd)
        echohl None
        return
    endif

    let ctags_opt = meflib#get('ctags_config', 'opt', '')
    let out_file_name = printf('%s/.tagdir/%s_tags', cwd, &filetype)
    if &filetype == 'cpp'
        let ft = 'c++'
    else
        let ft = &filetype
    endif
    let out_dir = fnamemodify(out_file_name, ':h')
    if !isdirectory(out_dir)
        call mkdir(out_dir)
    endif

    let ctags_cmds = printf('%s %s -f "%s" --languages=%s -R "%s"', ctags_cmd, ctags_opt, out_file_name, ft, cwd)
    echomsg ctags_cmds
    if has('nvim')
        call jobstart(ctags_cmds)
    else
        call job_start(ctags_cmds)
    endif
    echomsg 'done!'
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

" timer {{{
highlight Timer ctermbg=15 ctermfg=0 cterm=Bold guibg=White guifg=Black gui=Bold
function! meflib#tools#timer(second) abort
    if !has('timers')
        echo 'timer is not supported.'
        return
    endif
    let tid = timer_start(a:second*1000, expand('<SID>')..'timer_cb', {'repeat': 1})
    let tid2 = timer_start(1000, function(expand('<SID>')..'timer_update', [a:second, localtime()]), {'repeat': -1})
    echomsg printf('timer set (%d)', tid)
endfunction

let s:t_bufid = -1
let s:t_winid = -1
function! s:timer_update(set_time, st_time, timer_id) abort
    let rem_time = a:set_time-(localtime()-a:st_time)
    if rem_time < 0
        call meflib#floating#close(s:t_winid)
        " let s:t_bufid = -1
        let s:t_winid = -1
        call timer_stop(a:timer_id)
        return
    endif

    let H = rem_time/3600
    let M = (rem_time%3600)/60
    let S = rem_time%60
    let t_str = printf('%d:%d:%d', H, M, S)
    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines-3,
                \ 'col': &columns-1,
                \ 'pos': 'botright',
                \ 'highlight': 'Timer',
                \ }
    let [s:t_bufid, s:t_winid] = meflib#floating#open(s:t_bufid, s:t_winid, [t_str], config)
endfunction

function! s:timer_cb(tid) abort
    redraw
    let snooze_time = meflib#get('snooze_time', 60*10)
    echo 'time has passed (q to exit, s to snooze)'
    while v:true
        let key = getcharstr()
        if key == 'q'
            echo 'exit'
            break
        elseif key == 's'
            call meflib#tools#timer(snooze_time)
            echo printf('snoozed %d sec', snooze_time)
            break
        endif
    endwhile
endfunction
" }}}
