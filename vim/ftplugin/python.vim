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
        echo 'if you want to see built-in function, set module as None'
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

    if !has('pythonx')
        echo "This vim doesn't support python and python3."
        pclose
    endif

    let l:mod = split(a:module, ' ')
    try
        if match(l:mod[0], 'matplotlib') != -1
            pythonx import matplotlib
            pythonx matplotlib.use('agg')
        endif
        if l:mod[0] != 'None'
            execute "pythonx import " . l:mod[0] . ' as tmpmod'
            echo "import " . l:mod[0]
        endif
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

    pythonx << EOF
import inspect
import vim
mod = vim.eval('l:mod[0]')
func = vim.eval('l:func')
try:
    if func == 'no_func':
        vim.current.buffer.append("In file: "+inspect.getsourcefile(tmpmod))
        vim.current.buffer.append('\n')
        source = inspect.getsource(tmpmod)
        for s in source.split('\n'):
            vim.current.buffer.append(s)
        del tmpmod
    else:
        if mod == 'None':
            exec('source = '+func+'.__doc__')
            for s in source.split('\n'):
                vim.current.buffer.append(s)
        else:
            exec('onoff = "%s" in tmpmod.__dict__' % (func))
            if onoff:
                exec('source = tmpmod.'+func+'.__doc__')
                for s in source.split('\n'):
                    vim.current.buffer.append(s)
            else:
                print('%s is not in %s' % (func, mod))
                vim.command('pclose')
            del tmpmod
except Exception as e:
    if 0:
        print(e)
    vim.current.buffer.append("Not available for this object.")
EOF

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

