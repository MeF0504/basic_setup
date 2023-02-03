scriptencoding utf-8

" 行単位で差分を取る
function! meflib#diffline#main(...) abort
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

