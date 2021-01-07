"vim script encording setting
scriptencoding utf-8

"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    execute 'set path+=' . substitute(expand($PYTHONPATH), ':', ',', 'g')
endif
set suffixesadd+=.py
" error format for quickfix https://vim-jp.org/vimdoc-ja/quickfix.html#errorformats
" if needed
" set errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

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
    " setlocal nowrap
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

    if has('python3')
        python3 from io import StringIO
    else
        python from io import BytesIO as StringIO
    endif

    pythonx << EOF
import vim
import sys
mod = vim.eval('l:mod[0]')
func = vim.eval('l:func')

# https://teratail.com/questions/107044
with StringIO() as f:
    sys.stdout = f
    try:
        if func == 'no_func':
            help(tmpmod)
        else:
            if mod == 'None':
                exec('help('+func+')')
            else:
                exec('help(tmpmod.'+func+')')
        source = f.getvalue()
    except Exception as e:
        source = e.__str__() + '\n\nNot available for this object.'

for s in source.split('\n'):
    vim.current.buffer.append(s)

sys.stdout = sys.__stdout__
if 'tmpmod' in locals():
    del tmpmod

EOF

    " }}}
endfunction
command! -nargs=1 PyHelp call s:python_help(<f-args>)

function! s:py_template()
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
command! Template :call s:py_template()

