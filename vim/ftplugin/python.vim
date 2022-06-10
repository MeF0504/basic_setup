"vim script encording setting
scriptencoding utf-8

"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    execute 'set path+=' . substitute(substitute(expand($PYTHONPATH), ':', ',', 'g'), ' ', '\\ ', 'g')
endif
set suffixesadd+=.py
" error format for quickfix https://vim-jp.org/vimdoc-ja/quickfix.html#errorformats
" if needed
set errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

command! -buffer PySyntax !python3 -m py_compile %

" help 確認用コマンド
function! s:python_help_old(module) abort
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

" pydocとかいう便利ツールがあるじゃん
function! s:python_help(module) abort
    let pydoc_cmd = meflib#get_local_var('pydoc_cmd', 'pydoc3')
    if !executable(pydoc_cmd)
        echohl ErrorMsg
        echo printf('this command requires %s.', pydoc_cmd)
        echohl None
        return
    endif

    let cmd = printf('%s %s', pydoc_cmd, a:module)
    let res = systemlist(cmd)

    pclose
    silent split PythonHelp
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    " setlocal nowrap
    setlocal nobuflisted
    setlocal previewwindow
    setlocal modifiable
    silent %delete _
    call append(0, res)
    setlocal nomodifiable
    normal! gg

endfunction

command! -buffer -nargs=1 PyHelp call s:python_help(<f-args>)

" template
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
command! -buffer Template :call s:py_template()

" debug command
command -buffer DebugPrint call append(line('.')-1, 'print("\033[32m#####debug {} \033[0m".format(""))')

