"vim script encording setting
set encoding=utf-8
scriptencoding utf-8

" vim (almost) self-made function file

""開いているファイル情報を表示（ざっくり）{{{
function! meflib#tools#fileinfo() abort
    let file = expand('%')
    if file == ''
        return
    endif
    if !has('pythonx')
        if has('win32') || has('win64')
            let s:ls = 'dir '
        else
            let s:ls='ls -l '
        endif
        execute "!" . s:ls . file
        return
    else
        pythonx << EOL
import vim
import os
try:
    import datetime
except ImportError as e:
    datetime_ok = False
else:
    datetime_ok = True

fname = vim.eval('file')
res = ''

# access
if os.access(fname, os.R_OK): res += 'r'
else: res += '-'
if os.access(fname, os.W_OK): res += 'w'
else: res += '-'
if os.access(fname, os.X_OK): res += 'x'
else: res += '-'

# time stamp
if datetime_ok:
    stat = os.stat(fname)
    # meta data update (UNIX), created (Windows)
    # dt = datetime.datetime.fromtimestamp(stat.st_ctime)
    # created (some OS)
    # dt = datetime.datetime.fromtimestamp(stat.st_birthtime)
    # last update
    dt = datetime.datetime.fromtimestamp(stat.st_mtime)
    # last access
    # dt = datetime.datetime.fromtimestamp(stat.st_atime)
    res += dt.strftime(' %Y/%m/%d-%H:%M:%S')
else:
    res += ' ????/??/??-?:?:?'

# file size
filesize = os.path.getsize(fname)
prefix = ''
if filesize > 1024**3:
    filesize /= 1024**3
    prefix = 'G'
elif filesize > 1024**2:
    filesize /= 1024**2
    prefix = 'M'
elif filesize > 1024:
    filesize /= 1024
    prefix = 'k'
res += ' ({:.1f} {}B)'.format(filesize, prefix)

# file name
res += '  '+fname
if os.path.islink(fname):
    res += ' => '+os.path.realpath(fname)

print(res)
EOL
    endif
endfunction
"}}}

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

" ファイルの存在チェック {{{
function! meflib#tools#Jump_path() abort
    let line = getline('.')
    "           ↓full path  ↓expand var ↓expand cfile
    let fname = fnamemodify(expand(expand('<cfile>')), ':p')
    let lnum = 1
    let yn = 'y'

    if line =~# '^\s*File ".*", line \d*,'
        " python error
        echo "python error line."
        let idx_l = stridx(line, '"')+1
        let idx_r = stridx(line, '"', idx_l)-1
        let fname = line[idx_l:idx_r]
        let idx_l = stridx(line, ', line ', idx_r)+7
        let idx_r = stridx(line, ', in', idx_l)-1
        let lnum = line[idx_l:idx_r]
    elseif line =~# '^.*:[0-9]\+:.*$'
        " grep results
        echo "grep result"
        let idx_r = stridx(line, ':')-1
        let fname = line[:idx_r]
        let idx_l = idx_r+2
        let idx_r = stridx(line, ':', idx_l)-1
        let lnum = line[idx_l:idx_r]
    elseif isdirectory(fname)
        " file
        let yn = input(printf('%s: directory. open in new tab? (y/s/[n]): ', fname))
    elseif filereadable(fname)
        " directory
        let yn = input(printf('%s: file. open in new tab? (y/s/[n]): ',fname))
    elseif fname[:6] ==# 'http://' || fname[:7] ==# 'https://'
        " URL
        let cmd = meflib#basic#get_exe_cmd()
        if !empty(cmd)
            let yn = input(printf('"%s": web url. open? (y/[n])', fname))
            if (yn == 'y')
                call system([cmd, fname])
            endif
        else
            echo 'command to open web url is not found.'
        endif
        return
    else
        echo printf('%s not exist.', fname)
        return
    endif

    if yn ==# 'y'
        execute "tabnew ".fname
        execute lnum
    elseif yn ==# 's'
        let cmd = meflib#basic#get_exe_cmd()
        if !empty(cmd)
            call system([cmd, fname])
        else
            echo 'command to open the file is not found.'
        endif
    endif
endfunction
" }}}

" 行単位で差分を取る {{{
function! meflib#tools#diff_line(...) abort
    " http://t2y.hatenablog.jp/entry/20110210/1297338263
    let help_str = ":DiffLine [file1:]start1[-end1] [file2:]start2[-end2]\n"
                \."if file is not specified, use current file.\n"
                \." e.g. :DiffLine 5-6 test/test.txt:7"

    if a:0 != 2
        echo "illegal input.\n".help_str
        return
    endif

    let idx11 = strridx(a:1, ':')
    if idx11 == -1
        let file1 = '%'
    else
        let file1 = a:1[:idx11-1]
    endif
    let idx12 = stridx(a:1, '-', idx11)
    if idx12 == -1
        let st1 = str2nr(a:1[idx11+1:])
        let end1 = st1
    else
        let st1 = str2nr(a:1[idx11+1:idx12-1])
        let end1 = str2nr(a:1[idx12+1:])
    endif

    let idx21 = strridx(a:2, ':')
    if idx21 == -1
        let file2 = '%'
    else
        let file2 = a:2[:idx21-1]
    endif
    let idx22 = stridx(a:2, '-', idx21)
    if idx22 == -1
        let st2 = str2nr(a:2[idx21+1:])
        let end2 = st2
    else
        let st2 = str2nr(a:2[idx21+1:idx22-1])
        let end2 = str2nr(a:2[idx22+1:])
    endif
    " echo file1.' '.st1.' '.end1.' '.file2.' '.st2.' '.end2

    " file check
    if file1 != '%'
        if !filereadable(expand(file1))
            echo "unable to read ".file1."\n".help_str
            return
        endif
        if (bufname(file1)=='')
            echo file1." is not in buffer. please open that.\n".help_str
            return
        endif
    endif
    if file2 != '%'
        if !filereadable(expand(file2))
            echo "unable to read ".file2."\n".help_str
            return
        endif
        if (bufname(file2)=='')
            echo file2." is not in buffer. please open that.\n".help_str
            return
        endif
    endif

    " set python command
    if has('python3')
        command! -nargs=1 TmpPython python3 <args>
    elseif has('python')
        command! -nargs=1 TmpPython python <args>
    else
        echoerr 'this command requires python or python3.'
        return
    endif

    " condition check
    if (st1 > end1) || (st2 > end2)
        echo "start is larger than end.\n".help_str
    endif
    " if end1 > line('$', win_findbuf(bufnr(file1))[0])
    "     echo "input number is larger than EOF.\n".help_str
    "     return
    " endif
    " if end2 > line('$', win_findbuf(bufnr(file2))[0])
    "     echo "input number is larger than EOF.\n".help_str
    "     return
    " endif

    let l1 = getbufline(file1, st1, end1)
    let l2 = getbufline(file2, st2, end2)

    pclose
    silent 7split DiffLine
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    setlocal nowrap
    setlocal nobuflisted
    setlocal previewwindow
    setlocal nofoldenable
    0,$ delete _

    TmpPython << EOF
import vim
import difflib

line1 = vim.eval('l1')
line2 = vim.eval('l2')

d = difflib.Differ()
ret = '\n'.join(d.compare(line1, line2)).split('\n')

# print(ret)
for r in ret:
    if r != '':
        vim.current.buffer.append(r)
EOF

    wincmd p
    delcommand TmpPython
endfunction
" }}}

" 自作grep {{{
" 補完
function! meflib#tools#grep_comp(arglead, cmdline, cursorpos) abort
    let cur_opt = split(a:cmdline, ' ', 1)[-1]
    if (match(cur_opt, '=') == -1)
        let opts = ['wd', 'dir', 'ex']
        return filter(map(opts, 'v:val."="'), '!stridx(v:val, a:arglead) && match(a:cmdline, v:val)==-1')
    elseif cur_opt =~ 'dir='
        let arg = split(cur_opt, '=', 1)[1]
        let files = split(glob(arg..'*'), '\n')
        if !empty(files)
            return map(files+['opened'], "'dir='..v:val")
        else
            return []
        endif
    else
        return []
    endif
endfunction

function! <SID>echo_gregrep_help()
    echo "usage..."
    echo ":GREgrep [wd=word] [dir=dir_path] [ex=extention]"
    echo "wd ... text to search. if a word is put in <>, search it as a word."
    echo "dir ... path to root directory or file for search."
    echo "        if dir=opened, search files in buffer"
    echo "ex ... file extention of target files."
    echo "       if ex=None, search all files."
    echo "e.g. :GREgrep wd=hoge ex=.vim dir=%:h:h"
    echo "e.g. :GREgrep wd=fuga ex=None"
    echo "e.g. :GREgrep wd=<are> dir=opened"
endfunction

function! meflib#tools#Mygrep(...)
    let def_dir = '.'
    if meflib#get('get_top_dir', 0) == 1
        let top_dir = meflib#basic#get_top_dir(expand('%:h'))
        if !empty(top_dir)
            let def_dir = top_dir
        endif
    endif
    let is_word = 0
    if a:0 == '0'
        let l:word = expand('<cword>')
        let is_word = 1
        let l:ft = '.' . expand('%:e')
        let l:dir = def_dir
    else
        let arg = meflib#basic#analythis_args_eq(a:1)

        if !has_key(arg, "wd") && !has_key(arg, "ex") && !has_key(arg, "dir")
            call s:echo_gregrep_help()
            return
        endif

        if has_key(arg, "wd")
            let l:word = arg["wd"]
            let l:word .= arg["no_key"]
            if l:word[0]=='<' && l:word[-1:]=='>'
                let is_word = 1
                let l:word = l:word[1:-2]
            endif
        else
            let l:word = expand('<cword>')
            let is_word = 1
        endif
        let l:ft =  has_key(arg,  "ex") ? arg["ex"] : expand('%:e')
        let l:dir = has_key(arg, "dir") ? expand(arg["dir"]) : '.'
    endif
    let l:word = fnameescape(l:word)

    let is_opened = 0
    if l:dir == 'opened'
        let is_opened = 1
    elseif !isdirectory(l:dir)
        echo 'input directory "' . l:dir . '" does not exist.'
        return
    endif

    if is_opened
        let l:dir = ''
        for i in range(1, tabpagenr('$'))
            let bufnrs = tabpagebuflist(i)
            for bn in bufnrs
                let bufname = bufname(bn)
                if (match(l:dir, bufname) == -1) && filereadable(bufname)
                    let l:dir .= ' '.bufname
                endif
            endfor
        endfor
    else
        let l:dir = substitute(l:dir, ' ', '\\ ', 'g')
    endif

    if &grepprg == "internal"
        if is_opened
            let files = l:dir
        elseif l:ft == 'None'
            let files = l:dir..'/**/*'
        else
            let files = l:dir..'/**/*'..l:ft
        endif
        if is_word
            let bra = '\<'
            let ket = '\>'
        else
            let bra = ''
            let ket = ''
        endif
        execute printf('vimgrep /%s%s%s/j %s', bra, l:word, ket, files)
    elseif &grepprg =~ "grep\ -[a-z]*r[a-z]*"
        " cclose
        "wincmd b
        if l:ft == 'None'
            let l:ft = ''
        else
            let l:ft = ' --include=\*' . l:ft
        endif
        let wd_opt = is_word ? ' -w ' : ''

        " execute printf('grep! %s %s "%s" %s', l:ft, wd_opt, l:word, l:dir)
        " いちいちterminalに戻らない様になる
        " https://zenn.dev/skanehira/articles/2020-09-18-vim-cexpr-quickfix
        let cmd = printf("cgetexpr system('%s %s %s \"%s\" %s')", &grepprg, l:ft, wd_opt, l:word, l:dir)
        " quickfix_title をいい感じにするためにexecute を使う
        execute cmd
        " cwindow -> copen to check if grep is finished.
        copen
    else
        echo "not supported grepprg"
    endif
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

" buffer を選んでtabで開く {{{
function! s:open_buffer_cb(mod, bang, wid, res) abort
    if a:res > 0
        if empty(a:mod)
            let mod = 'tab'
        else
            let mod = a:mod
        endif
        if a:bang ==# '!'
            let bufnr = a:res
            if getbufvar(bufnr, '&buftype') == 'popup'
                echo 'unable to open popup window'
                return
            endif
        else
            let bufnr = bufnr(s:bufs[a:res-1])
            if s:bufs[a:res-1] ==# '[No Name]' || bufnr <= 0
                echo 'No Name buffer is not supported yet.'
                return
            endif
        endif
        execute printf('%s %dsbuffer', mod, bufnr)
    endif
    unlet s:bufs
endfunction

function! meflib#tools#open_buffer(mod, bang) abort
    let s:bufs = []
    for i in range(1, bufnr('$'))
        if a:bang==#'!' || buflisted(i)
            let bname = bufname(i)
            if empty(bname)
                let buftype = getbufvar(i, '&buftype')
                if buftype == 'nofile'
                    let bname = '[Scratch]'
                elseif buftype == 'popup'
                    let bname = '[Popup]'
                elseif buftype == 'prompt'
                    let bname = '[Prompt]'
                else
                    let bname = '[No Name]'
                endif
            endif
            call add(s:bufs, bname)
        endif
    endfor
    if empty(s:bufs)
        echo 'No buffer'
        return
    endif
    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines/3,
                \ 'col': &columns/3,
                \ 'nv_border': 'single',
                \ }
    call meflib#floating#select(s:bufs, config,
                \ function(expand('<SID>')..'open_buffer_cb', [a:mod, a:bang]))
endfunction
" }}}
