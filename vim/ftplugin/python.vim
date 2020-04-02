"vim script encording setting
scriptencoding utf-8

"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    set path+=$PYTHONPATH
endif

" "Execute python script Ctrl-P
" function! g:ExecPy()
"     exe "!" . &ft . " %"
" endfunction
" command! Exec call ExecPy()
" nnoremap <silent><buffer> <C-P> :call ExecPy()<CR>

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
        execute 'python3 import ' . a:module
        python3 << EOF
import inspect
import vim
mod = vim.eval('a:module')
try:
    exec('vim.current.buffer.append("In file: " + inspect.getsourcefile(%s))' % mod)
    vim.current.buffer.append('\n')
    exec('source = inspect.getsource(%s)' % mod)
    for s in source.split('\n'):
        vim.current.buffer.append(s)
except:
    vim.current.buffer.append("Not available for this object.")
EOF

    elseif has('python')
        execute 'python import ' . a:module
        python << EOF
import inspect
import vim
mod = vim.eval('a:module')
try:
    exec('vim.current.buffer.append("In file: " + inspect.getsourcefile(%s))' % mod)
    vim.current.buffer.append('\n')
    exec('source = inspect.getsource(%s)' % mod)
    for s in source.split('\n'):
        vim.current.buffer.append(s)
except:
    vim.current.buffer.append("Not available for this object.")
EOF
    else
        echo 'python not supported!'
        pclose
    endif
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

" function! s:get_import_path(...)
" 
"     if a:0 == 0
"         let cmd = getline('.')
"         let module = split(cmd, ' ')[-1]
"     elseif a:0 == 1
"         let cmd = 'import ' . a:1
"         let module = a:1
"     endif
" 
"     if has('python3')
"         let l:py = 'python3'
"     elseif has('python')
"         let l:py = 'python'
"         python from __future__ import print_function
"     else
"         return
"     endif
" 
"     let l:res = execute(l:py . " " . cmd)
"     let l:pypath = execute(l:py . " print(" . module . ".__file__)")
"     let l:pypath = substitute(l:pypath, "\n", "", "g")
"     let l:pypath = substitute(l:pypath, ".pyc", ".py", "g")
"     if filereadable(l:pypath)
"         return l:pypath
"     else
"         return ""
"     endif
"     "execute "tabnew " . l:pypath
" endfunction
" 
" command! -nargs=? SearchLib execute s:get_import_path(<f-args>)=="" ?
"             \ "no match lib found" : 
"             \ "tabnew " . s:get_import_path(<f-args>)
" 
