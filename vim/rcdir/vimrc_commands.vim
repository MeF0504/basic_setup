" vim script encoding setting
scriptencoding utf-8
"" simple commands and short functions

augroup cmdLocal
    autocmd!
augroup END

"ファイルが読み込めない事があるので、その時用にread onlyをつけてencodeし直して開く関数 "{{{

function! s:noeol_reenc()
    if &endofline == 0
        if input("reencode? (y/[n])")=='y'
            setlocal readonly
            e ++enc=utf-8
        endif
    endif
endfunction

"そしてファイルを開くたびに行うようにautocmd化
autocmd cmdLocal BufRead * call s:noeol_reenc()
" }}}

"diff系command {{{

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
command! -nargs=1 -complete=file Diff vertical diffsplit <args>
"}}}

"開いているファイル情報を表示（ざっくり）{{{
function! s:fileinfo() abort
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
command! FileInfo call s:fileinfo()
"}}}

" 辞書（というか英辞郎）で検索 {{{
function! s:eijiro(word)
    let dic_file = meflib#get_local_var('dic_file', '')
    if filereadable(dic_file)
        " localに辞書ファイルがある場合はそれを参照
        execute "vimgrep /\\<".a:word."\\>/j "..dic_file
        return
    endif

    let url = '"https://eowf.alc.co.jp/search?q='.a:word.'"'
    let web_cmd = meflib#basic#get_exe_cmd()
    if !executable(web_cmd)
        echo 'command '.web_cmd.' is not supported in this system.'
        return
    endif
    call system(printf('%s %s', web_cmd, url))
endfunction
command -nargs=1 Eijiro call s:eijiro(<f-args>)
" }}}

" conflict commentを検索 {{{
command! SearchConf /<<<<<<<\|=======\|>>>>>>>
" }}}

" expandを打つのがめんどくさい {{{
command! -nargs=1 Echopand echo expand(<f-args>)
" }}}

" ipython を呼ぶ用 {{{
if executable('ipython')
    command! Ipython botright terminal ipython
endif
if executable('ipython2')
    command! Ipython2 botright terminal ipython2
endif
if executable('ipython3')
    command! Ipython3 botright terminal ipython3
endif
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
            " echo 'delete '.dc
            " sleep 1
        else
            " echo 'not delete '.dc
            " sleep 1
        endif
    endfor
endfunction
if v:vim_did_enter
    call s:del_comds()
else
    autocmd cmdLocal VimEnter * ++once call s:del_comds()
endif
" }}}

" ctags command {{{
function! s:exec_ctags(...) abort
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

    let ctags_opt = meflib#get_local_var('ctags_opt', '')
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
command! -nargs=? Ctags call s:exec_ctags(<f-args>)

" }}}

" job status check {{{
if has('job')
    function! <SID>chk_job_status() abort
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
    endfunction
    command! JobStatus call <SID>chk_job_status()
endif
" }}}

