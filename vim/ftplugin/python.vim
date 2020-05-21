"vim script encording setting
scriptencoding utf-8

"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    execute 'set path+=' . substitute(expand($PYTHONPATH), ':', ',', 'g')
endif
set suffixesadd+=.py

command! PySyntax !python -m py_compile %

function! s:python_help(module) abort
    " {{{
    if a:module == '-h'
        echo '>>> usage :PyHelp module [function]'
        return
    endif

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
    let l:mod = split(a:module, ' ')
    try
        execute "TmpPython import " . l:mod[0]
        echo "import " . l:mod[0]
    catch
        echo "module '" . l:mod[0] . "' doesn't found."
        pclose
        return
    endtry
    if len(l:mod) > 1
        let l:func = l:mod[1]
    else
        let l:func = 'no_func'
    endif

    TmpPython << EOF
import inspect
import vim
mod = vim.eval('l:mod[0]')
func = vim.eval('l:func')
try:
    if func == 'no_func':
        exec('vim.current.buffer.append("In file: " + inspect.getsourcefile(%s))' % mod)
        vim.current.buffer.append('\n')
        exec('source = inspect.getsource(%s)' % mod)
        for s in source.split('\n'):
            vim.current.buffer.append(s)
    else:
        exec('onoff = "%s" in %s.__dict__' % (func, mod))
        if onoff:
            exec('source = '+mod+'.'+func+'.__doc__')
            for s in source.split('\n'):
                vim.current.buffer.append(s)
        else:
            print('%s is not in %s' % (func, mod))
            vim.command('pclose')
except Exception as e:
    if 0:
        print(e)
    vim.current.buffer.append("Not available for this object.")
EOF

delcommand TmpPython
    " }}}
endfunction
command! -nargs=1 PyHelp call s:python_help(<f-args>)

function! s:py_templete()
    " {{{
    append
import os

def main():
    print('Hello, World!')

if __name__ == '__main__':
    main()

.
    " }}}
endfunction
command! Templete :call s:py_templete()

