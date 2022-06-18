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
    if !empty(web_cmd)
        echo 'command '.web_cmd.' is not supported in this system.'
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

" 開いているfile一覧 {{{
let s:cur_winID = win_getid()
function! meflib#tools#file_list() abort
    let l:fnames = {}
    " tab number
    for i in range(1,tabpagenr('$'))
        "buffer number of each window
        for bufn in tabpagebuflist(i)
            let l:fname = bufname(bufn)
            if (len(l:fname) > 0) && (l:fname[0] == '/')
                let l:fname = fnamemodify(l:fname,':~')
            endif
            let l:fnames[i . "-" . bufn] = l:fname
        endfor
    endfor

    let l:search_name = '.'
    while 1
        redraw!
        " for in # of tab
        for i in range(1,tabpagenr('$'))
            let l:disp = 0
            let l:tab_files = printf("%3d ", i)
            " for in # of window in 1 tab
            for j in range(1, tabpagewinnr(i, '$'))
                let win_winID = win_getid(j, i)
                if has('popupwin')
                    if match(popup_list(), win_winID) != -1
                        " popup window
                        continue
                    endif
                elseif has('nvim')
                    if !empty(nvim_win_get_config(win_winID)['relative'])
                        " floating window
                        continue
                    endif
                endif
                let bufn = tabpagebuflist(i)[j-1]
                if (v:version > 802) || ((v:version == 802) && has('patch1727'))
                    let curpos = getcurpos(win_winID)
                    let line_col = printf(' (%d-%d)', curpos[1], curpos[2])
                else
                    let ln = line('.', win_winID)
                    let line_col = printf(' (%d)', ln)
                endif
                "check if 'search word' in file name.
                if match(l:fnames[i . "-" . bufn], l:search_name) != -1
                    let l:disp = 1
                endif

                let mod = getbufvar(bufn, '&modified') ? '[+]' : ''
                let l:flist = printf('[ %s%s%s ]', l:fnames[i..'-'..bufn], mod, line_col)
                if getbufvar(bufn, '&filetype') == 'qf'
                    let l:flist = '[ QuickFix' . mod . ']'
                endif
                let l:tab_files .= l:flist
            endfor
            if l:disp == 1
                if tabpagenr() == i
                    echohl Search | echo l:tab_files | echohl None
                else
                    echo l:tab_files
                endif
            else
                echohl Comment | echo l:tab_files | echohl None
            endif
        endfor
        if tabpagenr('$') <= 1
            break
        endif
        let l:tabnr = input("'#' :jump to tab / 'q' :quit / 'p' :previous tab / 'FileName' :search file :>> ")
        " quit
        if l:tabnr == "q"
            redraw!
            return
        " move to previous tab
        elseif l:tabnr == "p"
            let l:tabnr = win_id2tabwin(s:cur_winID)[0]
        " check l:tabnr is number
        elseif str2nr(l:tabnr) != 0
            let l:tabnr = str2nr(l:tabnr)
        " set search word
        else
            let l:search_name = l:tabnr
            continue
        endif
        if (1 <= l:tabnr ) && (l:tabnr <= tabpagenr("$") )
            " get current page number
            let s:cur_winID = win_getid()
            execute("normal! " . l:tabnr . "gt")
            redraw!
            return
        endif
    endwhile
endfunction
" }}}

" termonal commandを快適に使えるようにする {{{
"" http://koturn.hatenablog.com/entry/2018/02/12/140000
function! s:open_term(bufname) abort
    let bufn = bufnr(a:bufname)
    if bufn == -1
        " throw 'E94: No matching buffer for ' . a:bufname
        echoerr 'No matching buffer for "' . a:bufname . '"'
        return 1        " 以上終了ということにしよう
    elseif exists('*term_list') && index(term_list(), bufn) == -1
        " throw a:bufname . 'is not a terminal buffer'
        echoerr '"' . a:bufname . '"is not a terminal buffer'
        return 1        " 以上終了ということにしよう
    endif
    let winids = win_findbuf(bufn)
    if empty(winids)
        execute term_getsize(bufn)[0] 'new'
        execute 'buffer' bufn
    else
        call win_gotoid(winids[0])
    endif
    return 0
endfunction

" https://qiita.com/shiena/items/1dcb20e99f43c9383783
function! s:set_term_opt(is_float, name, finish) abort
    let term_opt = {}

    let env = {}
    if has('win32') || has('win64')
        " 日本語Windowsの場合`ja`が設定されるので、入力ロケールに合わせたUTF-8に設定しなおす
        if executable('locale.exe')
            let env['LANG'] = systemlist('"locale.exe" -iU')[0]
        endif

        " remote連携のための設定
        if has('clientserver')
            call extend(env, {
                        \ 'GVIM': $VIMRUNTIME,
                        \ 'VIM_SERVERNAME': v:servername,
                        \ })
        endif

        if !has('nvim')
            call extend(term_opt, {
                        \ 'term_name': a:name.'_'.s:term_cnt,
                        \ 'cwd': $USERPROFILE,
                        \ })
            let s:term_cnt += 1
        endif
    endif
    if !has('nvim')
        if a:is_float
            call extend(term_opt, {
                        \ 'hidden': v:true,
                        \ 'curwin': v:false,
                        \ })
        else
            call extend(term_opt, {
                        \ 'curwin': v:true,
                        \ })
        endif
        call extend(term_opt, {
                    \ 'term_finish': a:finish,
                    \ 'ansi_colors': meflib#basic#get_term_color(),
                    \ })
    endif

    let term_opt.env = env
    return term_opt
endfunction

let s:term_cnt = 1
function! s:open_term_win(opts)
    " term_startでgit for windowsのbashを実行する
    let cmd = a:opts
    if empty(cmd)
        let cmd = meflib#get('win_term_cmd', ['bash.exe', '-l'])
        let term_fin = 'close'
    else
        let term_fin = 'open'
    endif

    let term_opt = s:set_term_opt(0, '!'.cmd[0], term_fin)
    if has('nvim')
        call termopen(cmd, term_opt)
        startinsert
    else
        call term_start(cmd, term_opt)
    endif
endfunction

function! s:open_term_float(opts) abort
    let float_opt = {
                \ 'relative': 'win',
                \ 'line': &lines/2-&cmdheight-1,
                \ 'col': 5,
                \ 'maxheight': &lines/2-&cmdheight,
                \ 'maxwidth': &columns-10,
                \ 'win_enter': 1,
                \ 'border': [],
                \ 'nv_border': "rounded",
                \ 'minwidth': &columns-10,
                \ 'minheight': &lines/2-&cmdheight,
                \ }
    let cmd = a:opts
    if empty(cmd)
        if has('win32') || has('win64')
            let cmd = meflib#get('win_term_cmd', ['bash.exe', '-l'])
        else
            let cmd = [&shell]
        endif
        let term_finish = 'close'
    else
        let term_finish = 'open'
    endif

    let term_opt = s:set_term_opt(1, '!'.cmd[0], term_finish)

    if has('nvim')
        highlight TermNormal ctermbg=None guibg=None
        call extend(float_opt, {'highlight': 'TermNormal'}, 'force')
        let [bid, pid] = meflib#floating#open(-1, -1, [], float_opt)
        call termopen(cmd, term_opt)
        startinsert
    else
        let bid = term_start(cmd, term_opt)
        if bid == 0
            echohl ErrorMsg
            echo 'fail to open the terminal.'
            echohl None
            return
        endif
        call meflib#floating#open(bid, -1, [], float_opt)
        let s:term_cnt += 1
        return
    endif
endfunction

function! meflib#tools#Terminal(...) abort
    if !has('terminal') && !has('nvim')
        echoerr "this vim doesn't support terminal!!"
        return
    endif

    let args_config = {'win':1, 'term':1}
    if a:0 == 0
        let opts = ''
    else
        let opts = a:1
    endif
    let opts = meflib#basic#analythis_args_hyp(opts, args_config)

    if has_key(opts, 'win')
        let win_opt = opts['win'][0]
    elseif !empty(meflib#get('term_default', ''))
        let win_opt = meflib#get('term_default', 'S')
    else
        let win_opt = 'S'
    endif

    let term_opt = ''
    if has('win32') || has('win64')
        if has_key(opts, 'term')
            let res = s:open_term(opts['term'][0])
            if res != 0
                " can't find buffer
                return
            endif
            if mode() != 't'
                normal! i
            endif
            return
        else
            if win_opt == 'S'
                botright new
            elseif win_opt == 'V'
                botright vertical new
            elseif win_opt == 'F'
                tabnew
            elseif win_opt == 'P'
                call s:open_term_float(opts['no_opt'])
                return
            else
                echo 'not a supported option. return'
                return
            endif
        endif
        call s:open_term_win(opts['no_opt'])

    else
        if has('nvim')
            if has_key(opts, 'term')
                let res = s:open_term(opts['term'][0])
                if res != 0
                    " can't find buffer
                    return
                endif
                if mode() != 't'
                    startinsert " neovimはstartinsertでTeminal modeになる
                endif
                return
            else
                if win_opt == 'S'
                    botright new
                elseif win_opt == 'V'
                    botright vertical new
                elseif win_opt == 'F'
                    tabnew
                elseif win_opt == 'P'
                    call s:open_term_float(opts['no_opt'])
                    return
                else
                    echo 'not a supported option. return'
                    return
                endif
            endif
            let term_opt .= join(opts['no_opt'])
            execute 'terminal '.term_opt
            " rename buffer
            execute "silent file ".substitute(expand('%'), ' ', '', 'g')
            startinsert

        else
            let term_header = ''
            if has_key(opts, 'term')
                let res = s:open_term(opts['term'][0])
                if res != 0
                    " can't find buffer
                    return
                endif
                if mode() != 't'
                    " startinsert は無効らしい
                    normal! i
                endif
                return
            else
                if win_opt == 'S'
                    let term_header = 'botright '
                elseif win_opt == 'V'
                    let term_header = 'botright vertical '
                elseif win_opt == 'F'
                    tabnew
                    let term_opt = ' ++curwin'.term_opt
                elseif win_opt == 'P'
                    call s:open_term_float(opts['no_opt'])
                    return
                else
                    echo 'not a supported option. return'
                    return
                endif
            endif
            let term_opt .= ' '.join(opts['no_opt'])
            execute term_header.'terminal '.term_opt
            " rename buffer
            execute "silent file ".substitute(expand('%'), ' ', '', 'g')
        endif
    endif

    setlocal nolist
    setlocal foldcolumn=0
    setlocal nonumber
endfunction
" }}}

" ファイルの存在チェック {{{
function! meflib#tools#Jump_path() abort
    let line = getline('.')
    let fname = fnamemodify(expand('<cfile>'), ':p')
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
    elseif isdirectory(fname)
        " file
        let yn = input(printf('%s: directory. open in new tab? (y/[n]): ', fname))
    elseif filereadable(fname)
        " directory
        let yn = input(printf('%s: file. open in new tab? (y/[n]): ',fname))
    elseif fname[:6] ==# 'http://' || fname[:7] ==# 'https://'
        " URL
        let cmd = meflib#basic#get_exe_cmd()
        if !empty(cmd)
            let yn = input(printf('"%s": web url. open? (y/[n])', fname))
            if (yn == 'y')
                call system(printf('%s %s', cmd, fname))
            endif
        else
            echo 'command to open web url is not found.'
        endif
        return
    else
        echo printf('%s not exist.', fname)
        return
    endif

    if yn == 'y'
        execute "tabnew ".fname
        execute lnum
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
     if !filereadable(expand(file1))
         echo "unable to read ".file1."\n".help_str
         return
     endif
     if (bufname(file1)=='')
         echo file1." is not in buffer. please open that.\n".help_str
         return
     endif
     if !filereadable(expand(file2))
         echo "unable to read ".file2."\n".help_str
         return
     endif
     if (bufname(file2)=='')
         echo file2." is not in buffer. please open that.\n".help_str
         return
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

        execute printf('grep! %s %s "%s" %s', l:ft, wd_opt, l:word, l:dir)
        " botright copen
        " set statusline="%t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ' '} "
    else
        echo "not supported grepprg"
    endif
endfunction
" }}}

" XPM test function {{{
function meflib#tools#xpm_loader()
    let file = expand('%')
    if has('gui_running')
        let is_gui = 1
    else
        let is_gui = 0
    endif
    pythonx << EOL
import vim
from xpm_loader import XPMLoader

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

