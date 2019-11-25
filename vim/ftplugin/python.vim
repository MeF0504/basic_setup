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

function! s:get_import_path(...)

    if a:0 == 0
        let cmd = getline('.')
        let module = split(cmd, ' ')[-1]
    elseif a:0 == 1
        let cmd = 'import ' . a:1
        let module = a:1
    endif
    let l:res = execute("python " . cmd)
    let l:pypath = execute("python print " . module . ".__file__")
    let l:pypath = substitute(l:pypath, "\n", "", "g")
    let l:pypath = substitute(l:pypath, ".pyc", ".py", "g")
    if filereadable(l:pypath)
        return l:pypath
    else
        return ""
    endif
    "execute "tabnew " . l:pypath
endfunction

command! -nargs=? SearchLib execute s:get_import_path(<f-args>)=="" ?
            \ "no match lib found" : 
            \ "tabnew " . s:get_import_path(<f-args>)
