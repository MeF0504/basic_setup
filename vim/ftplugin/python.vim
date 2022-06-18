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

" これはlspで代替出来ると思うので一旦コメントアウト
" command! -buffer PySyntax !python3 -m py_compile %

" help 確認用コマンド
" pydocとかいう便利ツールがあるじゃん
function! s:python_help(module) abort
    " {{{
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
    if has('win32') || has('win64')
        %s///g
    endif
    setlocal nomodifiable
    normal! gg
    " }}}
endfunction

command! -buffer -nargs=1 PyHelp call s:python_help(<f-args>)

" debug command
command -buffer DebugPrint call append(line('.')-1, 'print("\033[32m#####debug {} \033[0m".format(""))')

" \ で終わったときのindent量を設定
" $VIMRUNTIME/indent/python.vim
let g:pyindent_continue = shiftwidth()

" PEP8より
" https://pep8-ja.readthedocs.io/ja/latest/
" 最長文字をccで確認はしたいが，折返しはしたくない...
setlocal textwidth=79
setlocal formatoptions-=tc

