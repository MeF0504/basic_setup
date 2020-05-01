"vim script encording setting
scriptencoding utf-8

"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    execute 'set path+=' . substitute(expand($PYTHONPATH), ':', ',', 'g')
endif
set suffixesadd+=.py

function! s:python_help(module) abort

    pclose
    silent split PythonHelp
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    setlocal nowrap
    setlocal nobuflisted
    setlocal previewwindow

    if has('python3')
        command! -nargs=1 TmpPython python3 <args>
    elseif has('python')
        command! -nargs=1 TmpPython python <args>
    else
        echo "This vim doesn't support python and python3."
        pclose
    endif
    try
        execute "TmpPython import " . a:module
        echo "import " . a:module
    catch
        echo "module '" . a:module . "' doesn't found."
        pclose
        return
    endtry

    TmpPython << EOF
import inspect
import vim
mod = vim.eval('a:module')
try:
    exec('vim.current.buffer.append("In file: " + inspect.getsourcefile(%s))' % mod)
    vim.current.buffer.append('\n')
    exec('source = inspect.getsource(%s)' % mod)
    for s in source.split('\n'):
        vim.current.buffer.append(s)
except Exception as e:
    if 0:
        print(e)
    vim.current.buffer.append("Not available for this object.")
EOF

delcommand TmpPython
endfunction

command! -nargs=1 PyHelp call s:python_help(<f-args>)

function! s:py_templete()
    append
import os

def main():
    print('Hello, World!')

if __name__ == '__main__':
    main()

.
endfunction
command! Templete :call s:py_templete()

