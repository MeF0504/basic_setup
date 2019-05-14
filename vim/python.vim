"vim script encording setting
scriptencoding utf-8

"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    set path+=$PYTHONPATH
endif

"Execute python script Ctrl-P
function! g:ExecPy()
    exe "!" . &ft . " %"
endfunction
command! Exec call ExecPy()
nnoremap <silent><buffer> <C-P> :call ExecPy()<CR>

function! s:get_import_path(lib)
    let l:res = execute("python import " . a:lib)
    let l:pypath = execute("python print " . a:lib . ".__file__")
    let l:pypath = substitute(l:pypath, "\n", "", "g")
    let l:pypath = substitute(l:pypath, ".pyc", ".py", "g")
    if filereadable(l:pypath)
        return l:pypath
    else
        return ""
    endif
    "execute "tabnew " . l:pypath
endfunction

command! -nargs=1 SearchLib execute "tabnew " . s:get_import_path(<f-args>)
