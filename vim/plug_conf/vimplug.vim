
" Anywhere SID.
function! s:SID_PREFIX() " tentative
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
if empty(expand('<SID>'))
    let s:sid = s:SID_PREFIX()
else
    let s:sid = expand('<SID>')
endif


" joke command
Plug 'MeF0504/sl.vim', PlugCond(1, {'on': 'SL'})

" Syntax 情報をpopupで表示
Plug 'MeF0504/vim-popsyntax', PlugCond(1, {'on': 'PopSyntaxToggle'})
" popsyntax {{{
let g:popsyntax_match_enable = 1
" }}}

" ctagsを使ってhighlightを設定 (mftags 分割 その1)
Plug 'MeF0504/highlightag.vim'
"" highlightag {{{
if has('nvim')
    autocmd PlugLocal VimEnter,BufWinEnter *
    \ if &filetype == 'c' |
    \ silent call highlightag#run_hitag_job_file() |
    \ else |
    \ silent call highlightag#run_hitag_job() |
    \ endif
else
    autocmd PlugLocal Syntax *
    \ if &filetype == 'c' |
    \ silent call highlightag#run_hitag_job_file() |
    \ else |
    \ silent call highlightag#run_hitag_job() |
    \ endif
endif
" highlights
function! <SID>highlightag_his() abort
    highlight default HiTagClasses ctermfg=171 guifg=#d75fff
    highlight default HiTagMembers ctermfg=69 guifg=#5f87ff
endfunction
call meflib#add('plugin_his', s:sid.'highlightag_his')
" }}}

" vim plugin like chrome://dino
Plug 'MeF0504/dino.vim', PlugCond(1, {'on': 'Dino'})

" color codeに色を付ける
Plug 'MeF0504/hicolcode.vim', PlugCond(1, {'on': 'ColCode'})
" {{{ hicolcode.vim
function! s:bash_syntax(line, idx) abort
    let match_list = {
                \ '\\e\[30m': [0, 0, 0],
                \ '\\e\[31m': [150, 0, 0],
                \ '\\e\[32m': [0, 150, 0],
                \ '\\e\[33m': [150, 150, 0],
                \ '\\e\[34m': [0, 0, 150],
                \ '\\e\[35m': [150, 0, 150],
                \ '\\e\[36m': [0, 150, 150],
                \ '\\e\[37m': [200, 200, 200],
                \ '\\e\[40m': [0, 0, 0],
                \ '\\e\[41m': [150, 0, 0],
                \ '\\e\[42m': [0, 150, 0],
                \ '\\e\[43m': [150, 150, 0],
                \ '\\e\[44m': [0, 0, 150],
                \ '\\e\[45m': [150, 0, 150],
                \ '\\e\[46m': [0, 150, 150],
                \ '\\e\[47m': [200, 200, 200],
                \ '\\e\[90m': [150, 150, 150],
                \ '\\e\[91m': [255, 0, 0],
                \ '\\e\[92m': [0, 255, 0],
                \ '\\e\[93m': [255, 255, 0],
                \ '\\e\[94m': [0, 0, 255],
                \ '\\e\[95m': [255, 0, 255],
                \ '\\e\[96m': [0, 255, 255],
                \ '\\e\[97m': [255, 255, 255],
                \ '\\e\[100m': [150, 150, 150],
                \ '\\e\[101m': [255, 0, 0],
                \ '\\e\[102m': [0, 255, 0],
                \ '\\e\[103m': [255, 255, 0],
                \ '\\e\[104m': [0, 0, 255],
                \ '\\e\[105m': [255, 0, 255],
                \ '\\e\[106m': [0, 255, 255],
                \ '\\e\[107m': [255, 255, 255],
                \}
    for [ptrn, rgb] in items(match_list)
        if match(a:line, ptrn, a:idx) != -1
            return rgb+[ptrn]
        endif
    endfor
    return []
endfunction
function! s:vim_cterm_hi(line, idx) abort
    let num = str2nr(split(a:line[a:idx+8:])[0])
    let ptrn = 'cterm[fb]g=\zs'..num..'\ze\s'
    if num < 16
        let rgb = [
                    \ [0, 0, 0], [150, 0, 0], [0, 150, 0], [150, 150, 0],
                    \ [0, 0, 150], [0, 150, 150], [150, 0, 150], [200, 200, 200],
                    \ [150, 150, 150], [255, 0, 0], [0, 255, 0], [255, 255, 0],
                    \ [0, 0, 255], [0, 255, 255], [255, 0, 255], [255, 255, 255],
                    \ ]
        return rgb[num]+[ptrn]
    elseif num < 232
        let r = (num-16)/36
        let g = (num-16-r*36)/6
        let b = num-16-r*36-g*6
        let r = r == 0 ? 0 : 55+40*r
        let g = g == 0 ? 0 : 55+40*g
        let b = b == 0 ? 0 : 55+40*b
        return [r, g, b, ptrn]
    elseif num < 256
        let wb = 8+10*(num-232)
        return [wb, wb, wb, ptrn]
    else
        return []
    endif
endfunction

let g:hicolcode_config = get(g:, 'hicolcode_config', {})
let g:hicolcode_config.sh = [
            \ {
                \ 'ptrn': '\\e\[[0-9]\+m',
                \ 'func': expand('<SID>')..'bash_syntax',
                \}
            \]
let g:hicolcode_config.vim = [
            \ {
                \ 'ptrn': 'cterm[fb]g=[0-9]\+',
                \ 'func': expand('<SID>')..'vim_cterm_hi',
                \ }
                \ ]
" }}}

" 簡易，柔軟 outliner生成器
Plug 'MeF0504/outliner.vim', PlugCond(1, {'on': 'OutLiner'})
" {{{ outliner.vim
function! s:outliner_hook() abort
    let g:outliner_settings = get(g:, 'outliner_settings', {})

    let g:outliner_settings._ = get(g:outliner_settings, '_', {})
    call extend(g:outliner_settings._, {
                \ 'function': {
                    \ 'pattern': '^{',
                    \ 'line': -1,
                    \}
                \}, 'keep')

    let g:outliner_settings.vim = get(g:outliner_settings, 'vim', {})
    call extend(g:outliner_settings.vim, {
                \ 'function': {
                    \ 'pattern': '^\s*function',
                    \ 'line': 0,
                    \ },
                \ 'map': {
                    \ 'pattern': '^[a-z]*map ',
                    \ 'line': 0,
                    \},
                \ 'Plug': {
                    \ 'pattern': '^Plug ',
                    \ 'line': 0,
                    \},
                \}, 'keep')
    let g:outliner_settings.bib = get(g:outliner_settings, 'bib', {})
    call extend(g:outliner_settings.bib, {
                \ 'article': {
                    \ 'pattern': '^@',
                    \ 'line': 0,
                    \},
                \ }, 'keep')
    let g:outliner_settings.sshconfig = get(g:outliner_settings, 'sshconfig', {})
    call extend(g:outliner_settings.sshconfig, {
                \ 'host': {
                    \ 'pattern': '^Host\>',
                    \ 'line': 0,
                    \ },
                \ }, 'keep')

    let g:outliner_settings.python = get(g:outliner_settings, 'python', {})
    call extend(g:outliner_settings.python, {
                \ 'function': {
                    \ 'pattern': '^\s*def\s',
                    \ 'line': 0,
                    \},
                \ 'class': {
                    \ 'pattern': '^\s*class\s',
                    \ 'line': 0,
                    \},
                \}, 'keep')

    let g:outliner_settings.markdown = get(g:outliner_settings, 'markdown', {})
    call extend(g:outliner_settings.markdown, {
                \ 'title': {
                    \ 'pattern': '^\s*#\+\s',
                    \ 'line': 0,
                    \},
                \}, 'keep')

    let g:outliner_settings.tex = get(g:outliner_settings, 'tex', {})
    call extend(g:outliner_settings.tex, {
                \ 'section': {
                    \ 'pattern': '^\s*\\.*section{.*}',
                    \ 'line': 0,
                    \},
                \ 'label': {
                    \ 'pattern': '^\s*\\label{.*}',
                    \ 'line': 0,
                    \},
                \ }, 'keep')

    let g:outliner_settings.fish = get(g:outliner_settings, 'fish', {})
    call extend(g:outliner_settings.fish, {
                \ 'function': {
                    \ 'pattern': '^\s*function\s',
                    \ 'line': 0,
                    \},
                \ 'var': {
                    \ 'pattern': '^\s*set\s',
                    \ 'line': 0,
                    \},
                \ 'alias': {
                    \ 'pattern': '^\s*alias\s',
                    \ 'line': 0,
                    \},
                \}, 'keep')
endfunction
autocmd PlugLocal User outliner.vim call s:outliner_hook()
nnoremap <silent> <Leader>o <Cmd>OutLiner<CR>
" }}}

" git log 表示用plugin
Plug 'MeF0504/gitewer.vim', PlugCond(1, {'on': 'Gitewer'})

" vim上でpetを飼う
Plug 'MeF0504/vim-pets', PlugCond(1, {'on': 'Pets'})
" {{{ vim-pets
function! s:pets_hook() abort
    let g:pets_garden_pos = [&lines-&cmdheight-2, &columns, 'botright']
    let g:pets_lifetime_enable = 0
    let g:pets_birth_enable = 1
endfunction
autocmd PlugLocal User vim-pets call s:pets_hook()
" }}}
Plug 'MeF0504/vim-pets-ocean', PlugCond(1, {'on': 'Pets'})
Plug 'MeF0504/vim-pets-codes', PlugCond(1, {'on': 'Pets'})

" paste時に履歴から選ぶ
Plug 'MeF0504/RegistPaste.vim'

" tab の一覧表示＆ジャンプ
Plug 'MeF0504/vim-TabJumper', PlugCond(1, {'on': 'TabJump'})
" TabJumper {{{
nnoremap <leader>l <Cmd>TabJump<CR>
" }}}

" neosnippet用のsnipets
Plug 'Shougo/neosnippet-snippets'

" コード実行plugin
Plug 'thinca/vim-quickrun', PlugCond(1, {'on': 'QuickRun'})
"" vim-quick_run {{{
let g:quickrun_no_default_key_mappings = 1
function! s:quickrun_hook() abort
    " default configs {{{
    let g:quickrun_config = get(g:, 'quickrun_config', {})  " 変数がなければ初期化
    " show errors in quickfix window
    let g:quickrun_config._ = get(g:quickrun_config, '_', {})
    call extend(g:quickrun_config._, {
        \ 'outputter' : 'error',
        \ 'outputter/multi/targets' : ['buffer', 'quickfix'],
        \ 'outputter/error/success' : 'buffer',
        \ 'outputter/error/error'   : 'multi',
        \ 'hook/time/enable'        : 1,
        \ },
        \ 'keep')
    if has('job')
        let g:quickrun_config._.runner = 'job'
        let quickrun_status = "%#StatusLine_CHK#%{quickrun#is_running()?'>...':''}%#StatusLine#"
        let cur_status = meflib#get('statusline', '_', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]")
        call meflib#set('statusline', '_', cur_status..quickrun_status)
    endif

    " python
    let g:quickrun_config.python = {
                \ 'command' : 'python3'
                \ }

    " markdown
    if has('mac')
        let s:cmd = 'open'
        let s:exe = '%c %s -a Google\ Chrome'
    elseif has('win32') || has('win64')
        let s:cmd = 'start'
        let s:exe = '%c chrome %s'
    else
        let s:cmd = 'firefox &'   " temporary
        let s:exe = '%c %s'
    endif
    let g:quickrun_config.markdown = {
                \ 'command' : s:cmd,
                \ 'exec' : s:exe
                \}

    " tex
    if has('mac')
        " macOSでlatex (ptex2pdf)を使う場合
        " https://texwiki.texjp.org/?quickrun
        if isdirectory('/Applications/Skim.app')
            let s:open_tex_pdf = 'open -a Skim '
        else
            let s:open_tex_pdf = 'open '
        endif
        let g:quickrun_config.tex = {
                    \ 'command' : 'ptex2pdf',
                    \ 'exec' : ['%c -l -u -ot "-synctex=1 -interaction=nonstopmode" %s -output-directory %s:h', s:open_tex_pdf.'%s:r.pdf']
                    \ }
    endif

    autocmd PlugLocal FileType quickrun setlocal nolist
    " }}}
endfunction
autocmd PlugLocal User vim-quickrun call s:quickrun_hook()
" wrapper functions {{{
function! <SID>echo_err() abort
    echohl ErrorMsg
    echo '[qrun-wrapper] qrun_func is not set.'
    echohl None
endfunction

function! <SID>quickrun_wrapper()
    " load quickrun
    if !get(g:, 'loaded_quickrun', 0)
        let quickrun_plugs = ['vim-quickrun']
        if has('nvim')
            let quickrun_plugs += ['vim-quickrun-neovim-job', 'vim-quickrun-runner-nvimterm']
        endif
        call plug#load(quickrun_plugs)
    endif

    if &modified
        echo 'file is not saved.'
        return
    endif
    if quickrun#is_running()
        echo 'quickrun is already running'
        return
    endif
    cclose
    let qrun_conf = findfile('.qrun_conf.vim', fnameescape(expand('%:p:h'))..';')
    if !empty(qrun_conf)
        echomsg printf('[qrun-wrapper] configure file is found ... %s', qrun_conf)
        call meflib#set('qrun_finished', 0)
        execute 'source '..qrun_conf
        if meflib#get('qrun_finished', 0)
            return
        endif
    endif
    echomsg '[qrun-wrapper] use default settings.'
    QuickRun
endfunction
" }}}

" .qrun_conf.vim sample {{{
" let make_file = findfile('Makefile', expand('%:p:h')..';')
" if !empty(make_file)
"     let q_config = {
"                 \ 'command': 'make',
"                 \ 'exec' : '%c',
"                 \ }
"     call quickrun#run(q_config)
"     call meflib#set('qrun_finished', 1)
" else
"     call meflib#set('qrun_finished', 0)
" endif

" hope to read .vscpde/launch.json...
" h json_decode()
" https://code.visualstudio.com/docs/editor/debugging#_launch-configurations
" https://code.visualstudio.com/docs/editor/debugging#_launchjson-attributes
" https://code.visualstudio.com/docs/editor/variables-reference
" }}}

nnoremap <silent> <Leader>q <Cmd>call <SID>quickrun_wrapper()<CR>
" }}}

" job runner of quickrun for Neovim (unofficial)
Plug 'lambdalisue/vim-quickrun-neovim-job', PlugCond(has('nvim'))
"" vim-auickrun-neovim-job {{{
function! s:quickrun_nvim_job_hook() abort
    " 変数がなければ初期化
    let g:quickrun_config = get(g:, 'quickrun_config', {})
    let g:quickrun_config._ = get(g:quickrun_config, '_', {})
    let g:quickrun_config._.runner = 'neovim_job'
    let quickrun_status = "%#StatusLine_CHK#%{quickrun#is_running()?'>...':''}%#StatusLine#"
    let cur_status = meflib#get('statusline', '_', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]")
    call meflib#set('statusline', '_', cur_status..quickrun_status)
endfunction
" plugin directoryが無いとlazy loadはされないらしい。それもそうか。
autocmd PlugLocal User vim-quickrun if has('nvim') | call s:quickrun_nvim_job_hook() | endif
" }}}

" terminal runner of quickrun for Neovim (unofficial)
Plug 'statiolake/vim-quickrun-runner-nvimterm', PlugCond(has('nvim'))
"" vim-auickrun-runner-nvimterm {{{
" to check nvimterm is loaded
autocmd PlugLocal User vim-quickrun if has('nvim') | call meflib#set('quickrun_nvimterm', 1) | endif
" }}}

" 背景透過
Plug 'miyakogi/seiya.vim', PlugCond(1, {'on': ['SeiyaEnable', 'SeiyaDisable']})
"" seiya.vim "{{{
let g:seiya_auto_enable=0
if has('termguicolors') && !has('gui_running')
    let g:seiya_target_groups = ['ctermbg', 'guibg']
endif
function! <SID>seiya_his() abort
    if &background == 'light'
        silent SeiyaDisable
    elseif g:colors_name =~ 'pjsekai_*'
        silent SeiyaDisable
    else
        SeiyaEnable
    endif
endfunction
call meflib#add('plugin_his', s:sid.'seiya_his')
"}}}

" 関数一覧を表示
" repo = 'vim-scripts/taglist.vim'
Plug 'yegappan/taglist', PlugCond(1, {'on': 'TlistToggle'})
"" taglist.vim "{{{
let g:Tlist_Exit_OnlyWindow = 1
let g:Tlist_Show_One_File = 1
let g:Tlist_File_Fold_Auto_Close = 1
" 幅の設定
" gui offのときは自動で幅が変わらないようにする (バグる)
if has('gui_running')
    let s:Max_WinWidth = 45
    let g:Tlist_Inc_Winwidth = 1
else
    let s:Max_WinWidth = 35
    let g:Tlist_Inc_Winwidth = 0
endif
function! s:taglist_his()
    highlight MyTagListTagName cterm=None ctermfg=0 ctermbg=111 gui=NONE guifg=#101010 guibg=#a0b5ff
endfunction
call meflib#add('plugin_his', s:sid.'taglist_his')

function! <SID>Open_taglist() abort
    " {{{
    if exists('g:Tlist_Use_Right_Window')
        let l:tlist_right_old = g:Tlist_Use_Right_Window
    else
        let l:tlist_right_old = 0
    endif
    " guiの時はいらないかも？↓
    if winwidth(winnr()) > s:Max_WinWidth*3
        let g:Tlist_WinWidth = s:Max_WinWidth
    else
        let g:Tlist_WinWidth = (winwidth(winnr())/16)*5
    endif

    " 右端だと右側に開く
    if (winnr()==1 ) || (winnr() != winnr("1l"))
        let g:Tlist_Use_Right_Window = 0
    else
        let g:Tlist_Use_Right_Window = 1
    endif

    " 右側で表示して閉じた際にwinnrが変わる問題対応
    let winnr = -1
    if &filetype != 'taglist'
        let winnr = winnr()
        if getbufvar(tabpagebuflist()[0], '&filetype') == 'taglist'
            let winnr -= 1
        endif
    endif

    TlistToggle

    " when tablist is closed
    if (getbufvar(tabpagebuflist()[0], '&filetype') != 'taglist') &&
        \ (getbufvar(tabpagebuflist()[-1], '&filetype') != 'taglist')
        if winnr != -1
            execute winnr . 'wincmd w'
        endif
    endif
    let g:Tlist_Use_Right_Window = l:tlist_right_old
    " }}}
endfunction
nnoremap <silent> <Leader>t <Cmd>call <SID>Open_taglist()<CR>

function! s:tlist_all_comp(arglead, cmdline, cursorpos) abort
    " {{{
    ":h :command-completion-custom
    let arglead = tolower(a:arglead)
    let cmdline = tolower(a:cmdline)
    let cmd_args = split(cmdline, ' ', 1)
    if len(cmd_args) > 1+1
        " take only 1 argument. 1 is command itself ('tlistall').
        return []
    endif
    let opt_list = ['help', 'clear']
    call add(opt_list, '*.'..expand('%:e'))
    return filter(opt_list, '!stridx(tolower(v:val), arglead)')
    " }}}
endfunction

function! s:tlist_all(...) abort
    " {{{
    if !exists('g:loaded_taglist')
        call plug#load('taglist')
    endif
    let cwd = meflib#basic#get_top_dir(expand('%:h'))
    if empty(cwd)
        let cwd = '.'
    endif
    let tlist_session_name = cwd..'/'..meflib#get('tlist_session_name', '.tlist_session')
    if a:0 == 0
        let ext = ''
    elseif a:1 == 'help'
        echo ':TlistAll [args]'
        echo '    help  ... show this help.'
        echo '    clear ... delete session file if exists.'
        echo '    else  ... specify extension. e.g. "*.py".'
        return
    elseif a:1 == 'clear'
        if filereadable(tlist_session_name)
            call delete(tlist_session_name)
        else
            echohl WarningMsg
            echomsg printf('taglist session log file %s is not found.', tlist_session_name)
            echohl None
        endif
        return
    else
        let ext = a:1
    endif

    let g:Tlist_Show_One_File = 0
    if filereadable(tlist_session_name)
        execute printf('TlistSessionLoad %s', tlist_session_name)
        echomsg printf('load %s', tlist_session_name)
    else
        let exec_cmd = printf('TlistAddFilesRecursive %s %s', cwd, ext)
        execute exec_cmd
        execute printf('TlistSessionSave %s', tlist_session_name)
        echomsg printf("execute :%s", exec_cmd)
        echomsg printf("save at %s", tlist_session_name)
    endif
    TlistToggle
    " }}}
endfunction
command! -nargs=? -complete=customlist,s:tlist_all_comp TlistAll call s:tlist_all(<f-args>)
"}}}

" project内のファイル検索
Plug 'ctrlpvim/ctrlp.vim', PlugCond(1, {'on': 'CtrlP'})
"" ctrlp{{{
"nnoremap <leader>s :<C-U>CtrlP<CR>
let g:ctrlp_map = '<leader>s'
nnoremap <leader>s <Cmd>CtrlP<CR>
let g:ctrlp_by_filename = 0
let g:ctrlp_match_window = 'order:ttb,min:1,max:7,results:15'
let g:ctrlp_switch_buffer = 'e'

let s:ctrlp_help_bufid = -1
let s:ctrlp_help_popid = -1
" {{{ help
let s:ctrlp_help = [
        \ "<c-d>: Toggle between full-path search and filename only search.",
        \ "<c-r>: Toggle between the string mode and full regexp mode.",
        \ "<c-f>, <c-up>  : Scroll to the 'next' search mode in the sequence.",
        \ "<c-b>, <c-down>: Scroll to the 'previous' search mode in the sequence.",
        \ "<tab>: Auto-complete directory names under the current working directory inside the prompt.",
        \ "<s-tab>: Toggle the focus between the match window and the prompt.",
        \ "<esc>, <c-c>: Exit CtrlP.",
        \ "<c-a>: Move the cursor to the 'start' of the prompt.",
        \ "<c-e>: Move the cursor to the 'end' of the prompt.",
        \ "<c-w>: Delete a preceding inner word.",
        \ "<c-u>: Clear the input field.",
        \ "<c-n>: Next string in the prompt's history.",
        \ "<c-p>: Previous string in the prompt's history.",
        \ "<cr>:  Open the selected file in the 'current' window if possible.",
        \ "<c-t>: Open the selected file in a new 'tab'.",
        \ "<c-v>: Open the selected file in a 'vertical' split.",
        \ "<c-x>: Open the selected file in a 'horizontal' split.",
        \ "<c-y>: Create a new file and its parent directories.",
        \ ]
" }}}
function! <SID>show_ctrlp_help()
    if s:ctrlp_help_popid != -1
        call meflib#floating#close(s:ctrlp_help_popid)
        let s:ctrlp_help_popid = -1
        return
    endif
    let config = {
        \ 'relative': 'editor',
        \ 'line': &lines-7-&cmdheight-2,
        \ 'col': &columns-3,
        \ 'pos': 'botright',
        \ }
    let [s:ctrlp_help_bufid, s:ctrlp_help_popid] = meflib#floating#open(s:ctrlp_help_bufid, s:ctrlp_help_popid, s:ctrlp_help, config)
endfunction
function! <SID>echo_ctrlp_help() abort
    for str in s:ctrlp_help
        echo str
    endfor
endfunction
if has('nvim')
    " なんかfloating windowがコケる
    autocmd PlugLocal FileType ctrlp ++once nnoremap <buffer> <silent> ? <Cmd>call <SID>echo_ctrlp_help()<CR>
else
    autocmd PlugLocal FileType ctrlp ++once nnoremap <buffer> <silent> ? <Cmd>call <SID>show_ctrlp_help()<CR>
endif
"}}}

" current lineの関数表示用plugin (StatusLine用)
Plug 'tyru/current-func-info.vim'
" autocmd PlugLocal User current-func-info.vim call s:cfi_hook()
autocmd PlugLocal VimEnter * call s:cfi_hook()
"" current-func-info.vim {{{
" highlights
function! <SID>cfi_his() abort
    highlight default CFIPopup ctermbg=11 ctermfg=233 cterm=bold guibg=Yellow guifg=#121212 gui=Bold
endfunction
call meflib#add('plugin_his', s:sid.'cfi_his')

function! s:cfi_hook() abort
    if !exists('g:loaded_cfi')
        return
    endif
    let s:cfi_bufid = -1
    let s:cfi_popid = -1
    function! <SID>Show_cfi()
        if meflib#basic#get_local_var('cfi_on', 0) == 0
            call meflib#floating#close(s:cfi_popid)
            let s:cfi_popid = -1
            return
        endif
        if cfi#supported_filetype(&filetype) == 0
            return
        endif
        if has('nvim')
            let line = 0
        else
            let line = 1
        endif
        " let cfi = cfi#get_func_name()
        let cfi = cfi#format("%s()", "Top")
        let config = {
            \ 'relative': 'win',
            \ 'line': line,
            \ 'col': winwidth(0),
            \ 'pos': 'topright',
            \ 'highlight': 'CFIPopup',
            \ }
        let [s:cfi_bufid, s:cfi_popid] = meflib#floating#open(s:cfi_bufid, s:cfi_popid, [cfi], config)
    endfunction
    autocmd PlugLocal CursorMoved * call <SID>Show_cfi()
    autocmd PlugLocal WinLeave * call meflib#floating#close(s:cfi_popid) | let s:cfi_popid=-1
    autocmd PlugLocal QuitPre * call meflib#floating#close(s:cfi_popid) | let s:cfi_popid=-1
endfunction
" }}}

" 検索時にhit数をcountしてくれるplugin
Plug 'osyo-manga/vim-anzu', PlugCond(!meflib#get('load_plugin', 'hitspop', 0), {'on':[]})
"" vim-anzu {{{
if !meflib#get('load_plugin', 'hitspop', 0)
    " highlights
    function! <SID>anzu_his() abort
        highlight default AnzuPopup ctermfg=224 ctermbg=238 guifg=#ffd7d7 guibg=#444444
    endfunction
    call meflib#add('plugin_his', s:sid.'anzu_his')
    call meflib#add('lazy_plugins', 'vim-anzu')
    " max search count
    let g:anzu_search_limit = 3000
    " mapping
    nmap n <Plug>(anzu-n-with-echo)
    nmap N <Plug>(anzu-N-with-echo)

    let s:anzu_bufid = -1
    let s:anzu_popid = -1
    function! <SID>Show_anzu_float() abort
        if !exists('g:loaded_anzu')
            return
        endif
        let anzu_str = anzu#search_status()
        if empty(anzu_str)
            call meflib#floating#close(s:anzu_popid)
            let s:anzu_popid = -1
            return
        endif
        " update status. if it takes time, cancel this.
        AnzuUpdateSearchStatus
        let config = {
            \ 'relative': 'win',
            \ 'line': winheight(0),
            \ 'col': winwidth(0),
            \ 'pos': 'botright',
            \ 'highlight': 'AnzuPopup',
            \ }
            let [s:anzu_bufid, s:anzu_popid] = meflib#floating#open(s:anzu_bufid, s:anzu_popid, [anzu_str], config)
    endfunction
    nnoremap <silent> \ <Cmd>call anzu#clear_search_status() <bar> nohlsearch<CR>
    autocmd PlugLocal CursorMoved * call <SID>Show_anzu_float()
    autocmd PlugLocal TabLeave * call meflib#floating#close(s:anzu_popid) | let s:anzu_popid=-1
    autocmd PlugLocal QuitPre * call meflib#floating#close(s:anzu_popid) | let s:anzu_popid=-1
endif
" }}}

" if - endif 等を補完してくれるplugin
Plug 'tpope/vim-endwise'
"" endwise {{{
autocmd PlugLocal FileType html
        \ let b:endwise_addition = '\=submatch(0)=="html" ? "\</html\>" : submatch(0)=="head" ? "\</head\>" : submatch(0)=="body" ? "\</body\>" : submatch(0)=="script" ? "\</script\>" : "\</style\>"' |
        \ let b:endwise_words = 'html,head,body,script,style' |
        \ let b:endwise_syngroups = 'htmlTagName,htmlSpecialTagName'
" https://github.com/tpope/vim-endwise/issues/83
autocmd PlugLocal FileType tex
        \ let b:endwise_addition = '\="\\end" . matchstr(submatch(0), "{.\\{-}}")' |
        \ let b:endwise_words = 'begin' |
        \ let b:endwise_pattern = '\\begin{.\{-}}' |
        \ let b:endwise_syngroups = 'texSection,texBeginEnd,texBeginEndName,texStatement'
"}}}

" vim の document
Plug 'vim-jp/vimdoc-ja'
" {{{
" https://gorilla.netlify.app/articles/20190427-vim-help-jp.html
" helpを日本語優先にする
" if !has('nvim')
autocmd PlugLocal User vimdoc-ja set helplang=ja
" endif
" }}}

" command line と検索時に補完してくれるplugin
" {{{
" from https://github.com/gelguy/wilder.nvim
function! UpdateRemotePlugins(...)
    if has('nvim')
        " Needed to refresh runtime files
        let &rtp = &rtp
        UpdateRemotePlugins
    else
        " do nothing
    endif
endfunction

function! s:wilder_hook() abort

    " Default keys
    call wilder#setup({
                \ 'modes': ['/', '?'],
                \ 'enable_cmdline_enter': 0,
                \ 'next_key': '<Tab>',
                \ 'previous_key': '<S-Tab>',
                \ 'accept_key': '<Up>',
                \ 'reject_key': '<Down>',
                \ })

    " \v 付きでも動くようにする
    " https://github.com/gelguy/wilder.nvim/issues/56
    call wilder#set_option('pipeline', [
      \   wilder#branch(
      \     wilder#cmdline_pipeline(),
      \     [
      \       {_, x -> x[:1] ==# '\v' ? x[2:] : x},
      \     ] + wilder#search_pipeline(),
      \   ),
      \ ])

    if has('nvim')
        let mode = 'float'
    elseif has('popupwin')
        let mode = 'popup'
    else
        let mode = 'statusline'
    endif
    call wilder#set_option('renderer', wilder#popupmenu_renderer({
                \ 'mode': mode,
                \ 'highlighter': wilder#basic_highlighter(),
                \ }))
endfunction

" }}}
Plug 'gelguy/wilder.nvim', PlugCond(1, {'do': function('UpdateRemotePlugins'), 'on': []})
call meflib#add('lazy_plugins', 'wilder.nvim')
autocmd PlugLocal User wilder.nvim call s:wilder_hook()

" for deoplete and wilder
" vim でneovim 用 pluginを動かすためのplugin
Plug 'roxma/nvim-yarp', PlugCond(!has('nvim'))

" for deoplete and wilder
" vim でneovim 用 pluginを動かすためのplugin
Plug 'roxma/vim-hug-neovim-rpc', PlugCond(!has('nvim'))

" visual modeで選択した範囲をgcでコメントアウトしてくれるplugin
Plug 'tpope/vim-commentary'

" 検索のhit数をpopupで表示するplugin
Plug 'obcat/vim-hitspop', PlugCond(meflib#get('load_plugin', 'hitspop', 0))
" {{{
if meflib#get('load_plugin', 'hitspop', 0)
    " https://zenn.dev/obcat/articles/4ef6822de53b643bbd01
    " :nohlsearch で消える→ 自分は\で消える
    " 右下に表示
    let g:hitspop_line = 'winbot'
    let g:hitspop_column = 'winright'
    " highlights
    function! <SID>hitspop_his() abort
        highlight default hitspopNormal ctermfg=224 ctermbg=238 guifg=#ffd7d7 guibg=#444444
        highlight default hitspopErrorMsg ctermfg=9 ctermbg=238 guifg=Red guibg=#444444
    endfunction
    call meflib#add('plugin_his', s:sid.'hitspop_his')
endif
" }}}

" 英語翻訳プラグイン
" https://qiita.com/gorilla0513/items/37c80569ff8f3a1c721c
Plug 'skanehira/translate.vim', PlugCond(1, {'on': 'Translate'})
" {{{
let g:translate_popup_window = 0
let g:translate_source = 'en'
let g:translate_target = 'ja'
" }}}

" カーソル下の変数と同じ変数に下線
Plug 'itchyny/vim-cursorword'
" {{{
" デフォルトのhighlightをoff
let g:cursorword_highlight = 0
" 幾つかのfile typeではcursorwordをoff
autocmd PlugLocal FileType txt,help,markdown,taglist,outliner
            \ let b:cursorword = 0
" highlights
function! <SID>cursorword_his() abort
    highlight default CursorWord1 ctermfg=None ctermbg=None cterm=None guifg=NONE guifg=NONE gui=NONE
    highlight default CursorWord0 ctermfg=None ctermbg=None cterm=underline guifg=NONE guifg=NONE gui=Underline
    " CursorWord[01] is not supported? or CursorWord is required?
    highlight default CursorWord ctermfg=None ctermbg=None cterm=underline guifg=NONE guifg=NONE gui=Underline

endfunction
call meflib#add('plugin_his', s:sid.'cursorword_his')
" }}}

" An ecosystem of Vim/Neovim which allows developers to write plugins in Deno. だそうです
" for ddc.vim
Plug 'vim-denops/denops.vim', PlugCond(meflib#get('load_plugin', 'denops', 0))

" denops test
Plug 'vim-denops/denops-helloworld.vim', PlugCond(meflib#get('load_plugin', 'denops', 0))

" Filer
" fern plugins {{{
Plug 'lambdalisue/fern-hijack.vim'

Plug 'lambdalisue/fern-ssh', PlugCond(1, {'on': 'Fern'})
"" fern-ssh {{{
function! <SID>ssh_password() abort
    " https://qiita.com/wadahiro/items/977e4f820b4451a2e5e0
    " if !exists('s:pswd')
    let pswd = inputsecret('password: ')
    if !empty(pswd)
        let exec_cmd = ['echo '..pswd]
        let tmpfile = tempname()
        if has('win32') || has('win64')
            let tmpfile .= '.bat'
            call insert(exec_cmd, '@echo off')
        endif
        call writefile(exec_cmd, tmpfile, '')
        if executable('chmod')
            call system('chmod 700 '..tmpfile)
        endif
        let $SSH_ASKPASS = tmpfile
        if !exists('$DISPLAY')
            let $DISPLAY = 'dummy:0'
        endif
    endif
    " endif
endfunction
command! SetSshPass call <SID>ssh_password()
" }}}

Plug 'lambdalisue/fern-mapping-project-top.vim', PlugCond(1, {'on': 'Fern'})

Plug 'MeF0504/fern-mapping-search-ctrlp.vim', PlugCond(1, {'on': 'Fern'})
" {{{
let g:fern_search_ctrlp_root = 1
let g:fern_search_ctrlp_open_file = 1
" }}}

Plug 'lambdalisue/fern-renderer-nerdfont.vim', PlugCond(1, {'on': 'Fern'})
" fern-nerd-font {{{
function! s:fern_renderer_nerdfont() abort
    if meflib#get('load_plugin', 'nerdfont', 0)
        let g:fern#renderer = "nerdfont"
    else
        let g:fern#renderer = "default"
    endif
    let g:fern#renderer#nerdfont#indent_markers = 1
endfunction
autocmd PlugLocal User fern-renderer-nerdfont.vim call s:fern_renderer_nerdfont()
" }}}

Plug 'lambdalisue/fern-git-status.vim', PlugCond(1, {'on': 'Fern'})
" fern git status {{{
" 遅延loadするので
let g:fern_git_status_disable_startup = 0
let g:fern_git_status#disable_directories = 1
function! s:fern_git_status_hook() abort
    call fern_git_status#init()
endfunction
autocmd PlugLocal User fern-git-status.vim cal s:fern_git_status_hook()
" }}}
" }}}

Plug 'lambdalisue/fern.vim', PlugCond(1, {'on': 'Fern'})
"" Fern {{{
" default keymap off
let g:fern#disable_default_mappings = 1
" 見た目の設定
let g:fern#renderer#default#root_symbol = '@ '
let g:fern#renderer#default#collapsed_symbol = '|= '
let g:fern#renderer#default#expanded_symbol = '|+ '
let g:fern#renderer#default#leaf_symbol = '|- '
let g:fern#keepalt_on_edit = 1

" Fern-local map
function! s:set_fern_map()
    nmap <buffer> <CR> <Plug>(fern-action-open-or-enter)
    " Enterでopen/expand/collapse
    nmap <buffer><expr>
            \ <Plug>(fern-my-open-or-expand-or-collapse)
            \ fern#smart#leaf(
            \   "<Plug>(fern-action-open:select)",
            \   "<Plug>(fern-action-expand)",
            \   "<Plug>(fern-action-collapse)",
            \ )
    nmap <buffer> <CR> <Plug>(fern-my-open-or-expand-or-collapse)
    " shift-→ でexpand
    nmap <buffer> <S-Right> <Plug>(fern-action-expand)
    " shift-← でcollapse
    nmap <buffer> <S-Left> <Plug>(fern-action-collapse)
    " shift-↑ でleave
    nmap <buffer> <S-Up> <Plug>(fern-action-leave)
    " shift-↓ でenter
    nmap <buffer> <S-Down> <Plug>(fern-action-enter)
    " <c-t> でtabで開く
    nmap <buffer> <c-t> <Plug>(fern-action-open:tabedit)
    " <c-g> でゴミ箱
    nmap <buffer> <c-g> <Plug>(fern-action-trash)
    " <c-s> でsystemで開く
    nmap <buffer> <c-s> <Plug>(fern-action-open:system)
    " <c-f> で検索
    nmap <buffer> <c-f> <Plug>(fern-action-search-ctrlp:root)
    " <c-r> でreload
    nmap <buffer> <c-r> <Plug>(fern-action-reload)
endfunction
autocmd PlugLocal FileType fern call s:set_fern_map()

" host map
nnoremap <silent> <leader>n <Cmd>Fern . -drawer -toggle -reveal=%<CR>

" 色設定
function! <SID>fern_his() abort
    highlight default FernMarkedText ctermfg=196 guifg=#ff0000
    highlight default FernRootSymbol ctermfg=11 guifg=#ffff00
    highlight default FernBranchSymbol ctermfg=10 guifg=#00ff00
    highlight default FernBranchText ctermfg=2 guifg=#008000
    highlight default FernLeafSymbol ctermfg=43 guifg=#00af5f
    if &background == 'dark'
        highlight default FernRootText ctermfg=220 guifg=#d0d000
    else
        highlight default FernRootText ctermfg=100 guifg=#9a9a00
    endif
endfunction
call meflib#add('plugin_his', s:sid.'fern_his')
"" }}}

" indent のlevelを見やすくする
Plug 'nathanaelkane/vim-indent-guides'
"" indent-guides {{{
" vim 起動時に起動
let g:indent_guides_enable_on_vim_startup = 1
" 色は自分で設定
let g:indent_guides_auto_colors = 0
" 2個目のindentから色をつける
let g:indent_guides_start_level = 2
" 1文字分だけ色つけ
let g:indent_guides_guide_size = 1
" mapは無し
let g:indent_guides_default_mapping = 0
" highlights
function! <SID>indentguide_his() abort
    if &background == 'dark'
        highlight default IndentGuidesOdd ctermfg=17 ctermbg=17 guifg=#003851 guibg=#003851
        highlight default IndentGuidesEven ctermfg=54 ctermbg=54 guifg=#3f0057 guibg=#3f0057
    else
        highlight default IndentGuidesOdd ctermfg=159 ctermbg=159 guifg=#e0f8ff guibg=#e0f8ff
        highlight default IndentGuidesEven ctermfg=225 ctermbg=225 guifg=#ffe0fd guibg=#ffe0fd
    endif
endfunction
call meflib#add('plugin_his', s:sid.'indentguide_his')
" }}}

" vim 新機能用pluginっぽい
" showcase of new vim functions.
Plug 'vim/killersheep', PlugCond(has('patch-8.1.1705'), {'on': 'KillKillKill'})

" toml 用 syntax
Plug 'cespare/vim-toml', PlugCond(!has('patch-8.2.2106'), {'for': 'toml'})

" ファイルの一部のsyntax highlightを違うfiletypeにする
Plug 'inkarkat/vim-SyntaxRange', PlugCond(1, {'for': ['toml', 'markdown', 'vim']})
" {{{
function! s:syntaxRange_hook() abort
    if &filetype == 'toml'
        " call s:syntax_range_dein()
        " autocmdのタイミングが悪い (vim-tomlに上書きされる)ので，調整
        " autocmd PlugLocal BufNewFile,BufRead dein*.toml call s:syntax_range_dein()
        autocmd PlugLocal BufWinEnter dein*.toml call s:syntax_range_dein()
    elseif &filetype == 'markdown'
        " call s:syntax_range_md()
        autocmd PlugLocal BufWinEnter *.md call s:syntax_range_md()
    elseif &filetype == 'vim'
        call s:syntax_range_vim()
        autocmd PlugLocal BufWinEnter *.vim call s:syntax_range_vim()
    endif
endfunction
" https://qiita.com/tmsanrinsha/items/9670628aef3144c7919b
" Insertで戻る... 要検討 ... とりあえず:eで再表示
function! s:syntax_range_dein() abort
    let start = '^\s*hook_\%('.
                \ 'add\|source\|post_source\|post_update'.
                \ '\)\s*=\s*%s'
    call SyntaxRange#Include(printf(start, "\'\'\'"), "\'\'\'", 'vim', '')
    call SyntaxRange#Include(printf(start, '"""'), '"""', 'vim', '')
endfunction

function! s:syntax_range_md() abort
    call SyntaxRange#Include('^\s*```\s*vim', '```', 'vim', '')
endfunction

function! s:syntax_range_vim() abort
    let start = '^\s*python[3x]*.*EOL$'
    call SyntaxRange#Include(start, 'EOL', 'python', '')
endfunction
autocmd PlugLocal User vim-SyntaxRange call s:syntaxRange_hook()
" autocmd PlugLocal VimEnter * call s:syntaxRange_hook()
" }}}

" 上のpluginで使われるやつ
Plug 'inkarkat/vim-ingo-library', PlugCond(1, {'for': ['toml', 'markdown']})

" vim でsnippet を使う用の plugin (framework?)
Plug 'Shougo/neosnippet.vim'

" vim script 用補完 plugin
Plug 'Shougo/neco-vim', PlugCond(1, {'for': 'vim'})

let g:l_deo = meflib#get('load_plugin', 'deoplete', 0)
" dark powered 補完plugin
Plug 'Shougo/deoplete.nvim', PlugCond(g:l_deo, {'on':[]})
" {{{
if g:l_deo
    call meflib#add('insert_plugins', 'deoplete.nvim')
    let g:deoplete#enable_at_startup = 1
    inoremap <expr><tab> pumvisible() ? "\<C-n>" :
            \ neosnippet#expandable_or_jumpable() ?
            \    "\<Plug>(neosnippet_expand_or_jump)" : "\<tab>"
    inoremap <expr><S-tab> pumvisible() ? "\<C-p>" :
            \ neosnippet#expandable_or_jumpable() ?
            \    "\<Plug>(neosnippet_expand_or_jump)" : "\<S-tab>"

    "" test
    autocmd PlugLocal FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd PlugLocal FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd PlugLocal FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd PlugLocal FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd PlugLocal FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    " auto close preview window.
    autocmd PlugLocal CompleteDone * silent! pclose!
endif
" }}}
" syntax file から補完候補を作成
Plug 'Shougo/neco-syntax', PlugCond(g:l_deo)
" c言語用補完 plugin
Plug 'Shougo/deoplete-clangx', PlugCond(g:l_deo, {'for': 'c'})
" python 用補完 plugin
Plug 'deoplete-plugins/deoplete-jedi', PlugCond(g:l_deo, {'for': 'python'})
" zsh 用補完 plugin
Plug 'deoplete-plugins/deoplete-zsh', PlugCond(g:l_deo, {'for': 'zsh'})
unlet g:l_deo

" vimの編集履歴を表示／適用してくれる plugin
Plug 'sjl/gundo.vim', PlugCond(1, {'on': 'GundoToggle'})
" {{{ "Gundo
" if has('python3') " pythonをcheckするのに時間が掛かっているっぽい
let g:gundo_prefer_python3 = 1
" endif
nnoremap <silent> <Leader>u <Cmd>GundoToggle<CR>
" }}}

" vimでLSP (Language Server Protocol)を扱うためのplugin
Plug 'prabirshrestha/vim-lsp', PlugCond(0, {})
call meflib#add('lazy_plugins', 'vim-lsp')
"" vim-lsp {{{
" lazy load
let g:lsp_auto_enable = 0
" https://qiita.com/kitagry/items/216c2cf0066ff046d200
" doc diagは欲しいので，とりあえずsignだけ有効にしてみる。
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_diagnostics_signs_enabled = 1
let g:lsp_diagnostics_signs_insert_mode_enabled = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
" cursor上にwarningとかあったらechoしてくれる
let g:lsp_diagnostics_echo_cursor = 1
" highlightはvim-cursorwordで表示しているので使わない
let g:lsp_document_highlight_enabled = 0
" LspPeekDefinition で表示する位置
let g:lsp_peek_alignment = 'top'
" 文字入力中にhelpを非表示（なんか不安定なため）
let g:lsp_signature_help_enabled = 0
" cとかjsでcode actionを無効化
let g:lsp_document_code_action_signs_enabled = 0
" Nerd font ならwarningとかも変えようか
if meflib#get('load_plugin', 'nerdfont', 0)
    let g:lsp_diagnostics_signs_warning = {'text': nr2char(0xf071)}
    let g:lsp_diagnostics_signs_error = {'text': nr2char(0xfb8a)}
endif
" highlights
function! <SID>lsp_his() abort
    highlight default Lsp_Running ctermfg=233 ctermbg=183 guifg=#000000 guibg=#c8a0ef
    highlight default Lsp_NotRunning ctermfg=255 ctermbg=52 guifg=#eeeeee guibg=#702030
    if meflib#get('load_plugin', 'nerdfont', 0)
        " copy highlight of SignColumn
        let [ctermbg, guibg] = meflib#basic#get_hi_info('SignColumn', ['ctermbg', 'guibg'])
        if &background == 'dark'
            let cwarn = "226"
            let gwarn = "#f0f000"
        else
            let cwarn = "136"
            let gwarn = "#b0a000"
        endif
        execute printf("highlight default LspWarningText ctermfg=%s ctermbg=%s guifg=%s guibg=%s", cwarn, ctermbg, gwarn, guibg)
        execute printf("highlight default LspErrorText ctermfg=124 ctermbg=%s guifg=#d00000 guibg=%s", ctermbg, guibg)
    endif
endfunction
call meflib#add('plugin_his', s:sid.'lsp_his')

" reference: lsp_settings#profile#status()
function! <SID>chk_lsp_running(map_pop) " {{{
    let active_servers = lsp#get_allowed_servers()
    if empty(active_servers)
        if a:map_pop == 'map'
            echomsg 'No Language server'
            sleep 300ms
            return v:false
        else
            return 'No Lang Server'
        endif
    endif
    for active_server in active_servers
        let lsp_status = lsp#get_server_status(active_server)
        if lsp_status == 'running'
            if a:map_pop == 'popup'
                return printf('%s:%s', active_server, lsp_status)
            else
                return v:true
            endif
        endif
    endfor
    if a:map_pop == 'map'
        return v:false
    else
        return printf('%s:%s', active_server, lsp_status)
    endif
endfunction
" }}}
function! s:show_lsp_server_status(tid) abort " {{{
    let lsp_status = <SID>chk_lsp_running('popup')
    if has('nvim')
        let line = 1
    else
        let line = 2
    endif
    if lsp_status[match(lsp_status, ':')+1:] == 'running'
        let highlight = 'LSP_Running'
    else
        let highlight = 'Lsp_NotRunning'
    endif
    let config = {
                \ 'relative': 'editor',
                \ 'line': line,
                \ 'col': &columns,
                \ 'pos': 'topright',
                \ 'highlight': highlight,
                \ }
    let [s:lsp_bufid, s:lsp_popid] = meflib#floating#open(s:lsp_bufid, s:lsp_popid, [lsp_status], config)
endfunction
let s:lsp_popid = -1
let s:lsp_bufid = -1
" }}}
function! <SID>lsp_status_tab() abort " {{{
    let name_max = 8
    let lsp_status = <SID>chk_lsp_running('popup')
    let idx = strridx(lsp_status, ':')
    if idx == -1
        let name = lsp_status
        let status = ''
        let highlight = 'Lsp_NotRunning'
    else
        let name = lsp_status[:idx-1]
        if len(name) > name_max
            let name = name[:name_max-1]
        endif
        let status = lsp_status[idx+1:]
        if status == 'running'
            let highlight = 'LSP_Running'
        else
            let highlight = 'Lsp_NotRunning'
        endif
    endif
    let footer = printf('%%#%s#|%s:%s%%#%s#', highlight, name, status, 'TabLineFill')
    let len = len(name..':'..status)+1
    return [footer, len]
endfunction
" }}}
" lsp server が動いていれば<c-]>で定義に飛んで，<c-j>でreferencesを開く
" <c-p>でhelp hover, definition, type definition を選択
function! s:lsp_mapping(map) abort " {{{
    if a:map == 1
        echo 'open in; [t]ab/[s]plit/[v]ertical/cur_win '
        let yn = getcharstr()
        if yn == 't'
            return "\<Cmd>tab LspDefinition\<CR>"
        elseif yn == 's'
            return "\<Cmd>aboveleft LspDefinition\<CR>"
        elseif yn == 'v'
            return "\<Cmd>vertical LspDefinition\<CR>"
        elseif yn == "\<esc>"
            echo 'canceled'
            return ''
        else
            return "\<Plug>(lsp-definition)"
        endif
    elseif a:map == 2
        return "\<Plug>(lsp-references)"
    elseif a:map == 3
        let res = ""
        let old_cmdheight = &cmdheight
        let &cmdheight += 3
        echo  " 1: help\n"..
            \ " 2: definition\n"..
            \ " 3: type definition: "
        let num = getcharstr()
        if num == '1'
            let res = "\<Plug>(lsp-hover)"
        elseif num == '2'
            let res = "\<Plug>(lsp-peek-definition)"
        elseif num == '3'
            let res = "\<Plug>(lsp-peek-type-definition)"
        endif
        let &cmdheight = old_cmdheight
        redraw!
        if empty(res)
            echo 'canceled'
        endif
        return res
    endif
endfunction
" }}}
let s:lsp_map = {}
function! s:vim_lsp_hook() abort
    if !exists('g:lsp_loaded')
        return
    endif
    call lsp#enable()
    " mapping {{{
    let s:lsp_map[1] = empty(maparg('<c-]>', 'n')) ? '<c-]>' : maparg('<c-]>', 'n')
    let s:lsp_map[2] = empty(maparg('<c-j>', 'n')) ? '<c-j>' : maparg('<c-j>', 'n')
    let s:lsp_map[3] = empty(maparg('<c-p>', 'n')) ? '<c-p>' : maparg('<c-p>', 'n')
    execute "nmap <silent> <expr> <c-]> <SID>chk_lsp_running('map') ? <SID>lsp_mapping(1) : '"..s:lsp_map[1]."'"
    execute "nmap <silent> <expr> <c-j> <SID>chk_lsp_running('map') ? <SID>lsp_mapping(2) : '"..s:lsp_map[2]."'"
    execute "nmap <silent> <expr> <c-p> <SID>chk_lsp_running('map') ? <SID>lsp_mapping(3) : '"..s:lsp_map[3]."'"
    " help file でバグる？
    autocmd PlugLocal FileType help nnoremap <buffer> <c-]> <c-]>
    " }}}
    " autocmd {{{
    " normal modeでmouseが使えないとscroll出来ないので，とりあえず対処。
    " lsp_float_closed がvimだとpopupがcursor moveで閉じても叩かれない？ので，qで閉じるようにする
    autocmd PlugLocal User lsp_float_opened nnoremap <buffer> <expr> <c-d> lsp#scroll(+5)
    autocmd PlugLocal User lsp_float_opened nnoremap <buffer> <expr> <c-u> lsp#scroll(-5)
    autocmd PlugLocal User lsp_float_opened nnoremap <buffer> <expr> <c-e> lsp#scroll(+1)
    autocmd PlugLocal User lsp_float_opened nnoremap <buffer> <expr> <c-y> lsp#scroll(-1)
    autocmd PlugLocal User lsp_float_opened nmap <buffer> <silent> q <Plug>(lsp-preview-close)
    autocmd PlugLocal User lsp_float_closed nunmap <buffer> <c-d>
    autocmd PlugLocal User lsp_float_closed nunmap <buffer> <c-u>
    autocmd PlugLocal User lsp_float_closed nunmap <buffer> <c-e>
    autocmd PlugLocal User lsp_float_closed nunmap <buffer> <c-y>
    autocmd PlugLocal User lsp_float_closed nunmap <buffer> q
    if !has('nvim')
        autocmd PlugLocal User lsp_float_opened nunmap <buffer> <esc>   " tentative
    endif
    " }}}
    " show status {{{
    " call timer_start(1000, s:sid.'show_lsp_server_status', {'repeat':-1})
    " autocmd PlugLocal WinLeave * call meflib#floating#close(s:lsp_popid) | let s:lsp_popid = -1
    call meflib#set('tabline_footer', s:sid.'lsp_status_tab')
    " }}}
endfunction
autocmd PlugLocal User vim-lsp call s:vim_lsp_hook()
" autocmd PlugLocal VimEnter * call s:vim_lsp_hook()
"" }}}
" vim-lspの設定用plugin
Plug 'mattn/vim-lsp-settings', PlugCond(0, {})
call meflib#add('lazy_plugins', 'vim-lsp-settings')

" 新世代(2021) dark deno-powered completion framework
let g:l_ddc = meflib#get('load_plugin', 'denops', 0)
" plugins for ddc.vim {{{
" source
Plug 'Shougo/ddc-around', PlugCond(g:l_ddc)
Plug 'LumaKernel/ddc-file', PlugCond(g:l_ddc)
Plug 'LumaKernel/ddc-tabnine', PlugCond(g:l_ddc)
Plug 'shun/ddc-vim-lsp', PlugCond(g:l_ddc)
" matcher
Plug 'Shougo/ddc-matcher_head', PlugCond(g:l_ddc)
" sorter
Plug 'Shougo/ddc-sorter_rank', PlugCond(g:l_ddc)
" converter
Plug 'Shougo/ddc-converter_remove_overlap', PlugCond(g:l_ddc)
" UI
Plug 'Shougo/ddc-ui-native', PlugCond(g:l_ddc)
" }}}

Plug 'Shougo/ddc.vim', PlugCond(g:l_ddc)
" {{{
function! s:ddc_hook() abort
    echomsg 'ddc setting start'
    " set UI
    call ddc#custom#patch_global('ui', 'native')
    " add sources
    call ddc#custom#patch_global('sources', ['file', 'vim-lsp', 'around'])
    " set basic options
    call ddc#custom#patch_global(
        \ 'sourceOptions', {
            \ '_': {
                \ 'matchers': ['matcher_head'],
                \ 'sorters': ['sorter_rank'],
                \ 'converters': ['converter_remove_overlap'],
            \ },
        \ })

    " set sorce-specific options
    call ddc#custom#patch_global(
        \ 'sourceOptions', {
            \ 'around': {
                \ 'mark': 'A',
            \ },
            \ 'file': {
                \ 'mark': 'F',
                \ 'isVolatile': v:true,
                \ 'forceCompletionPattern': '\S/\S*',
            \ },
            \ 'tabnine': {
                \ 'mark': 'TN',
                \ 'maxCandidate': 5,
                \ 'isVolatile': v:true,
            \ },
            \ 'vim-lsp': {
                \ 'mark': 'lsp',
            \ },
        \ },
        \ 'sourceParams', {
            \ 'tabnine': {
                \ 'maxNumResults': 10,
                \ 'storageDir': expand('~/.cache/ddc-tabline'),
            \ },
        \ }
    \ )
    " storageDir doesn't work??

    " set filetype-specific options
    call ddc#custom#patch_filetype(['ps1', 'dosbatch', 'autohotkey', 'registry'], {
        \ 'sourceOptions': {
            \ 'file': {
                \ 'forceCompletionPattern': '\S\\\S*',
            \ },
        \ },
        \ 'sourceParams': {
            \ 'file': {
                \ 'mode': 'win32',
            \ },
        \ }
    \ })
    call ddc#custom#patch_filetype(['vim', 'toml'], {
        \ 'sources': ['necovim', 'file', 'around'],
        \ 'sourceOptions': {
            \ 'necovim': {
                \ 'mark': 'vim',
                \ 'maxCandidate': 5,
            \},
        \}
    \ })
    call ddc#custom#patch_filetype(['python', 'c', 'cpp'], {
        \ 'sources': ['file', 'vim-lsp', 'around', 'tabnine'],
    \ })

    " Mappings
    " <TAB>: completion.
    inoremap <silent><expr> <TAB>
    \ pumvisible() ? '<C-n>' :
    \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
    \ '<TAB>' : ddc#map#manual_complete()
    " <S-TAB>: completion back.
    inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

    " automatically close preview window.
    autocmd PlugLocal CompleteDone * silent! pclose!

    " on.
    call ddc#enable()

    echomsg 'ddc setting finish'
endfunction
if g:l_ddc
    " autocmd PlugLocal User ddc.vim call s:ddc_hook()
    autocmd PlugLocal InsertEnter * ++once call s:ddc_hook()
endif
" }}}
unlet g:l_ddc

" readme をhelpとして見れるようにする
let g:readme_viewer#plugin_manager = 'vim-plug'
Plug '4513ECHO/vim-readme-viewer', PlugCond(1, { 'on': 'PlugReadme' })

" カーソルの下の文字とかをhighlight
Plug 'azabiong/vim-highlighter', PlugCond(1, {'on': 'Hi'})
" {{{
" function! s:highlighter_hook() abort
" endfunction
" autocmd PlugLocal User vim-highlighter call s:highlighter_hook()
let g:HiClear = '\\'
nnoremap // :<c-u>Hi + 
" }}}

" git の現在行のコミット履歴を辿る
Plug 'rhysd/git-messenger.vim', PlugCond(1, {'on': 'GitMessenger'})
" git messenger {{{
let g:git_messenger_no_default_mappings = v:true
let g:git_messenger_floating_win_opts = {'border': 'single'}
nnoremap <leader>g <Cmd>GitMessenger<CR>
" }}}

" plugin のdot repeatをサポート (RegistPasteで使用)
Plug 'tpope/vim-repeat'

" syntax file etc. for fish script
Plug 'dag/vim-fish', PlugCond(1, {'for': 'fish'})

" a fundemental plugin to handle Nerd Fonts from Vim. (for Fern)
Plug 'lambdalisue/nerdfont.vim'

" vim bookmark
Plug 'MattesGroeger/vim-bookmarks', PlugCond(1, {'on': ['BookmarkToggle', 'BookmarkAnnotate']})
" bookmarks {{{
let g:bookmark_no_default_key_mappings = 1
let g:bookmark_auto_save = 0
let g:bookmark_disable_ctrlp = 1
let g:bookmark_display_annotation = 0
nnoremap <leader>mm <Cmd>BookmarkToggle<CR>
nnoremap <leader>mi <Cmd>BookmarkAnnotate<CR>
nnoremap <leader>ma <Cmd>BookmarkShowAll<CR>
function! s:bookmarks_his() abort
    let [ctermbg, guibg] = meflib#basic#get_hi_info('SignColumn', ['ctermbg', 'guibg'])
    execute printf("highlight default BookmarkSign ctermfg=105 ctermbg=%s guifg=#8787ff guibg=%s", ctermbg, guibg)
    execute printf("highlight BookmarkAnnotationSign ctermfg=51 ctermbg=%s guifg=#30ffe8 guibg=%s", ctermbg, guibg)
endfunction
call meflib#add('plugin_his', s:sid.'bookmarks_his')
" }}}
