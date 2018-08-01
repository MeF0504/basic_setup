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

