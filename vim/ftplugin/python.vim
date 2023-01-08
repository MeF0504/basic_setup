"vim script encording setting
scriptencoding utf-8

augroup PythonLocal
    autocmd!
augroup END

" set系 {{{
"gfの検索にPYTHON PATHを追加
if exists("$PYTHONPATH")
    execute 'set path+=' . substitute(substitute(expand($PYTHONPATH), ':', ',', 'g'), ' ', '\\ ', 'g')
endif
set suffixesadd+=.py
" error format for quickfix https://vim-jp.org/vimdoc-ja/quickfix.html#errorformats
" if needed
setlocal errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
" PEP8より
" https://pep8-ja.readthedocs.io/ja/latest/
" 最長文字をccで確認はしたいが，折返しはしたくない...
setlocal textwidth=79
setlocal formatoptions-=tc
setlocal colorcolumn=+1

" \ で終わったときのindent量を設定
" $VIMRUNTIME/indent/python.vim
let g:pyindent_continue = shiftwidth()
" }}}

" 簡易command {{{
" これはlspで代替出来ると思うので一旦コメントアウト
" command! -buffer PySyntax !python3 -m py_compile %

" debug command
command -buffer DebugPrint call append(line('.')-1, 'print("\033[32m#####debug {} \033[0m".format(""))')
" }}}

" help 確認用コマンド
" pydocとかいう便利ツールがあるじゃん
let s:pyhelp_id = -1
function! s:python_help(module) abort
    " {{{
    let pydoc_cmd = meflib#get('pydoc_cmd', 'pydoc3')
    if !executable(pydoc_cmd)
        echohl ErrorMsg
        echo printf('this command requires %s.', pydoc_cmd)
        echohl None
        return
    endif

    let cmd = printf('%s %s', pydoc_cmd, a:module)
    let res = systemlist(cmd)

    if s:pyhelp_id != -1
        call win_execute(s:pyhelp_id, 'quit')
    endif
    silent split PythonHelp
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    " setlocal nowrap
    setlocal nobuflisted
    setlocal nolist
    setlocal modifiable
    silent %delete _
    call append(0, res)
    " need to check ↓
    " if has('win32') || has('win64')
    "     %s///g
    " endif
    setlocal nomodifiable
    normal! gg
    let s:pyhelp_id = win_getid()
    execute printf("autocmd PythonLocal WinClosed %d ++once let s:pyhelp_id = -1", s:pyhelp_id)
    " }}}
endfunction
command! -buffer -nargs=1 PyHelp call s:python_help(<f-args>)

let s:hit_str = split('def class if else elif for with while try except', ' ')
" {{{ 今自分がどの関数/class/for/if内にいるのか表示する
function! <SID>ccpp_cb(res, wid, idx) abort
    if a:idx > 0
        let sel_res = a:res[a:idx-1]
        let lnum = sel_res[:match(sel_res, '|')-1]
        let lnum = substitute(lnum, '0', '', 'g')
        " save position. :h jumplist
        normal! m'
        call cursor(lnum, 1)
    endif
endfunction

function! <SID>chk_current_position_python() abort

    let res = []
    let tablevel = indent('.')
    let clnnr = line('.')
    for lnnr in range(clnnr)
        let ln = getline(clnnr-lnnr-1)
        let tmp_tablevel = indent(clnnr-lnnr-1)
        " echo tmp_tablevel . '-' . tablevel
        if tmp_tablevel < tablevel
            for hs in s:hit_str
                let is_hit = match(ln, '^\s*\<'.hs.'\>') != -1
                if is_hit
                    " echo ln
                    call insert(res, printf('%0'.len(line('.')).'d| %s', clnnr-lnnr-1, ln))
                    if match('elif else except', '\<'.hs.'\>') == -1
                        let tablevel = tmp_tablevel
                    endif
                endif
            endfor
        endif
    endfor

    if exists('g:vscode')
        for l in res
            echo l
        endfor
        return
    endif

    if empty(res)
        return
    endif
    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines-&cmdheight-1,
                \ 'col': &numberwidth+&signcolumn+2,
                \ 'pos': 'botleft',
                \ 'nv_border': 'single',
                \ }

    call meflib#floating#select(res, config, function(expand('<SID>')..'ccpp_cb', [res]))
endfunction
" MatchupWhereAmI は python だと動かないっぽいので自作を復元
nnoremap <buffer> <leader>c <Cmd>call <SID>chk_current_position_python()<CR>
" }}}

" match-upはpython 非対応らしいので，自作 {{{
function! <SID>next_identifer_python() abort
    if match(s:hit_str, expand('<cword>')) != -1 &&
       \ match(getline('.'), '^\s*'..expand('<cword>')) != -1
        let ind_level = indent('.')
    else
        return '%'
    endif

    for lnum in range(line('.')+1, line('$'))
        let match = indent(lnum)
        if !empty(getline(lnum)) && match<=ind_level
            return lnum.'gg'
        endif
    endfor
    return '%'
endfunction
" match-up より前に%をmapするとmatch-upが他言語でもmapされないっぽいので。
if exists('g:loaded_matchup')
    nnoremap <buffer><silent><expr> % <SID>next_identifer_python()
else
    autocmd PythonLocal VimEnter * ++once nnoremap <buffer><silent><expr> % <SID>next_identifer_python()
endif
" }}}

