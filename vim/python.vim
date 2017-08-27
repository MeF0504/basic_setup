
"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    set path+=$PYTHONPATH
endif

"Execute python script Ctrl-P
function! s:ExecPy()
    exe "!" . &ft . " %"
    :endfunction
    command! Exec call <SID>ExecPy()
    autocmd local FileType python map <silent> <C-P> :call <SID>ExecPy()<CR>

