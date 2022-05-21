
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

" 単語に色を付ける
Plug 'MeF0504/vim-wordcolor'
"" wordcolor {{{
let g:word_color_mapping = '//'
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
" }}}

" color codeに色を付ける
Plug 'MeF0504/hicolcode.vim', PlugCond(1, {'on': 'ColCode'})

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
                    \ 'pattern': '^@article',
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
endfunction
" }}}
autocmd PlugLocal User outliner.vim call s:outliner_hook()

" neosnippet用のsnipets
Plug 'Shougo/neosnippet-snippets'

" git log 表示用plugin
Plug 'MeF0504/gitewer.vim', PlugCond(1, {'on': 'Gitewer'})

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
        let s:quickrun_status = "%#StatusLine_CHK#%{quickrun#is_running()?'>...':''}%#StatusLine#"
        let s:cur_status = meflib#get_local_var('statusline', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]", '_')
        call meflib#set_local_var('statusline', s:cur_status..s:quickrun_status, '_')
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
    let qrun_conf = findfile('.qrun_conf.vim', expand('%:p:h')..';')
    if !empty(qrun_conf)
        echomsg printf('[qrun-wrapper] configure file is found ... %s', qrun_conf)
        call meflib#set_local_var('qrun_finished', 0)
        execute 'source '..qrun_conf
        if meflib#get_local_var('qrun_finished', 0)
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
"                 \ 'exec' : ['%c']
"     }
"     call quickrun#run(q_config)
"     call meflib#set_local_var('qrun_finished', 1)
" else
"     call meflib#set_local_var('qrun_finished', 0)
" endif
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
    let s:quickrun_status = "%#StatusLine_CHK#%{quickrun#is_running()?'>...':''}%#StatusLine#"
    let s:cur_status = meflib#get_local_var('statusline', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]", '_')
    call meflib#set_local_var('statusline', s:cur_status..s:quickrun_status, '_')
endfunction
autocmd PlugLocal User vim-quickrun-neovim-job call s:quickrun_nvim_job_hook()
" }}}

" terminal runner of quickrun for Neovim (unofficial)
Plug 'statiolake/vim-quickrun-runner-nvimterm', PlugCond(has('nvim'))
"" vim-auickrun-runner-nvimterm {{{
" to check nvimterm is loaded
autocmd PlugLocal User vim-quickrun-runner-nvimterm call meflib#set_local_var('quickrun_nvimterm', 1)
" }}}

" 背景透過
Plug 'miyakogi/seiya.vim'
"" seiya.vim "{{{
"vimの背景を透過
let g:seiya_auto_enable=1
if has('termguicolors') && !has('gui_running')
    let g:seiya_target_groups = ['ctermbg', 'guibg']
endif
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

function! Open_taglist() abort
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
nnoremap <silent> <Leader>t <Cmd>call Open_taglist()<CR>

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
    let cwd = meflib#basic#get_top_dir(expand('%:h'))
    if empty(cwd)
        let cwd = '.'
    endif
    let tlist_session_name = cwd..'/'..meflib#get_local_var('tlist_session_name', '.tlist_session')
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
autocmd PlugLocal FileType ctrlp ++once nnoremap <buffer> <silent> ? <Cmd>call <SID>show_ctrlp_help()<CR>
"}}}

" current lineの関数表示用plugin (StatusLine用)
Plug 'tyru/current-func-info.vim'
" autocmd PlugLocal User current-func-info.vim call s:cfi_hook()
autocmd PlugLocal VimEnter * call s:cfi_hook()
"" current-func-info.vim {{{
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
Plug 'osyo-manga/vim-anzu', PlugCond(!meflib#get_local_var('load_plugin', 0, 'hitspop'))
"" vim-anzu {{{
if !meflib#get_local_var('load_plugin', 0, 'hitspop')
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

" for deoplete
" vim でneovim 用 pluginを動かすためのplugin
Plug 'roxma/nvim-yarp', PlugCond(!has('nvim'))

" for deoplete
" vim でneovim 用 pluginを動かすためのplugin
Plug 'roxma/vim-hug-neovim-rpc', PlugCond(!has('nvim'))

" visual modeで選択した範囲をgcでコメントアウトしてくれるplugin
Plug 'tpope/vim-commentary'

" 検索のhit数をpopupで表示するplugin
Plug 'obcat/vim-hitspop', PlugCond(meflib#get_local_var('load_plugin', 0, 'hitspop'))
" {{{
if meflib#get_local_var('load_plugin', 0, 'hitspop')
    " https://zenn.dev/obcat/articles/4ef6822de53b643bbd01
    " :nohlsearch で消える→ 自分は\で消える
    " 右下に表示
    let g:hitspop_line = 'winbot'
    let g:hitspop_column = 'winright'
endif
" }}}

" 英語翻訳プラグイン
" https://qiita.com/gorilla0513/items/37c80569ff8f3a1c721c
Plug 'skanehira/translate.vim'
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
highlight CursorWord1 ctermfg=None ctermbg=None cterm=None
highlight CursorWord0 ctermfg=None ctermbg=None cterm=underline
" }}}

" An ecosystem of Vim/Neovim which allows developers to write plugins in Deno. だそうです
" for ddc.vim
Plug 'vim-denops/denops.vim', PlugCond(meflib#get_local_var('load_plugin', 0, 'denops'))

" denops test
Plug 'vim-denops/denops-helloworld.vim', PlugCond(meflib#get_local_var('load_plugin', 0, 'denops'))

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
    nmap <buffer> <c-f> <Plug>(fern-action-search-ctrlp:cursor)
endfunction
autocmd PlugLocal FileType fern call s:set_fern_map()

" host map
nnoremap <silent> <leader>n <Cmd>Fern . -drawer -toggle -reveal=%<CR>

" 色設定
function! s:set_fern_hi()
    highlight FernMarkedText ctermfg=196 guifg=#ff0000
    highlight FernRootSymbol ctermfg=11 guifg=#ffff00
    highlight FernRootText ctermfg=220 guifg=#d0d000
    highlight FernBranchSymbol ctermfg=10 guifg=#00ff00
    highlight FernBranchText ctermfg=2 guifg=#008000
    highlight FernLeafSymbol ctermfg=43 guifg=#00af5f
    " highlight FernLeafText ctermfg=41 guifg=#00d75f
endfunction
" autocmd PlugLocal User FernHighlight call s:set_fern_hi()
autocmd PlugLocal Colorscheme * call s:set_fern_hi()
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
" 1も自分だけ色つけ
let g:indent_guides_guide_size = 1
" mapは無し
let g:indent_guides_default_mapping = 0
" }}}

" vim 新機能用pluginっぽい
" showcase of new vim functions.
Plug 'vim/killersheep', PlugCond(has('patch-8.1.1705'))

" toml 用 syntax
Plug 'cespare/vim-toml', PlugCond(has('patch-8.2.2106'))

" ファイルの一部のsyntax highlightを違うfiletypeにする
Plug 'inkarkat/vim-SyntaxRange', PlugCond(1, {'for': ['toml', 'markdown', 'vim']})
" {{{
function! s:syntaxRange_hook() abort
    if &filetype == 'toml'
        call s:syntax_range_dein()
        " autocmdのタイミングが悪い (vim-tomlに上書きされる)ので，調整
        " autocmd PlugLocal BufNewFile,BufRead dein*.toml call s:syntax_range_dein()
        autocmd PlugLocal BufWinEnter dein*.toml call s:syntax_range_dein()
    elseif &filetype == 'markdown'
        call s:syntax_range_md()
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

if meflib#get_local_var('load_plugin', 0, 'deoplete')
    " dark powered 補完plugin
    Plug 'Shougo/deoplete.nvim'
    " {{{
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
    " }}}
    " syntax file から補完候補を作成
    Plug 'Shougo/neco-syntax'
    " c言語用補完 plugin
    Plug 'Shougo/deoplete-clangx', {'for': 'c'}
    " python 用補完 plugin
    Plug 'deoplete-plugins/deoplete-jedi', {'for': 'python'}
    " zsh 用補完 plugin
    Plug 'deoplete-plugins/deoplete-zsh', {'for': 'zsh'}
endif

Plug 'sjl/gundo.vim', PlugCond(1, {'on': 'GundoToggle'})
" {{{ "Gundo
if has('python3')
    let g:gundo_prefer_python3 = 1
endif
nnoremap <silent> <Leader>u <Cmd>GundoToggle<CR>
" }}}

Plug 'prabirshrestha/vim-lsp'
"" vim-lsp {{{
" https://qiita.com/kitagry/items/216c2cf0066ff046d200
" errorとかwarning表示はとりあえずoff
let g:lsp_diagnostics_enabled = 0
" highlightはvim-cursorwordで表示しているので使わない
let g:lsp_document_highlight_enabled = 0
" LspPeekDefinition で表示する位置
let g:lsp_peek_alignment = 'top'
" 文字入力中にhelpを非表示
let g:lsp_signature_help_enabled = 0
" cとかjsでcode actionを無効化
let g:lsp_document_code_action_signs_enabled = 0

" reference: lsp_settings#profile#status()
function! <SID>chk_lsp_running(echo)
    let active_servers = lsp#get_allowed_servers()
    if empty(active_servers)
        if a:echo
            echomsg 'no Language server'
        endif
        return 0
    endif
    for active_server in active_servers
        let lsp_status = lsp#get_server_status(active_server)
        if lsp_status == 'running'
            return 1
        elseif a:echo
            echomsg lsp_status
            sleep 300ms
        endif
    endfor
    return 0
endfunction
" lsp server が動いていれば<c-]>で定義に飛んで，<c-j>でreferencesを開く
" <c-p>でhelp hover, definition, type definition を選択
function! <SID>chk_tab_jump()
    echo 'open in new tab? [y]/n: '
    let yn = nr2char(getchar())
    if yn != 'n'
        return ":tab LspDefinition\<CR>"
    else
        return "\<Plug>(lsp-definition)"
    endif
endfunction

function! <SID>select_float()
    let res = ""
    let old_cmdheight = &cmdheight
    set cmdheight=4
    echo  " 1: help\n"..
        \ " 2: definition\n"..
        \ " 3: type definition: "
    let num = nr2char(getchar())
    if num == '1'
        let res = "\<Plug>(lsp-hover)"
    elseif num == '2'
        let res = "\<Plug>(lsp-peek-definition)"
    elseif num == '3'
        let res = "\<Plug>(lsp-peek-type-definition)"
    endif
    let &cmdheight = old_cmdheight
    redraw!
    return res
endfunction

function! s:vim_lsp_hook() abort
    if !exists('g:lsp_loaded')
        return
    endif
    let lsp_map1 =  maparg('<c-]>', 'n')
    if empty(lsp_map1)
        let lsp_map1 = '<c-]>'
    endif
    let lsp_map2 =  maparg('<c-j>', 'n')
    if empty(lsp_map2)
        let lsp_map2 = '<c-j>'
    endif
    let lsp_map3 =  maparg('<c-p>', 'n')
    if empty(lsp_map3)
        let lsp_map3 = '<c-p>'
    endif
    execute "nmap <silent> <expr> <c-]> <SID>chk_lsp_running(1)==1 ? <SID>chk_tab_jump() : '"..lsp_map1."'"
    execute "nmap <silent> <expr> <c-j> <SID>chk_lsp_running(1)==1 ? '<Plug>(lsp-references)' : '".lsp_map2."'"
    execute "nmap <silent> <expr> <c-p> <SID>chk_lsp_running(1)==1 ? <SID>select_float() : '".lsp_map3."'"
    " help file でバグる？
    autocmd PlugLocal FileType help nnoremap <buffer> <c-]> <c-]>

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
endfunction
" autocmd PlugLocal User vim-lsp call s:vim_lsp_hook()
autocmd PlugLocal VimEnter * call s:vim_lsp_hook()
"" }}}
Plug 'mattn/vim-lsp-settings'

if meflib#get_local_var('load_plugin',0,'denops') " &&(denops#server#status()=='running')
    " 新世代(2021) dark deno-powered completion framework
    " plugins for ddc.vim {{{
    Plug 'Shougo/ddc-around'
    Plug 'Shougo/ddc-matcher_head'
    Plug 'Shougo/ddc-sorter_rank'
    Plug 'LumaKernel/ddc-file'
    Plug 'LumaKernel/ddc-tabnine'
    Plug 'shun/ddc-vim-lsp'
    Plug 'Shougo/ddc-converter_remove_overlap'
    " }}}

    Plug 'Shougo/ddc.vim'
    " {{{
    function! s:ddc_hook() abort
        echomsg 'ddc setting start'
        " add sources
        call ddc#custom#patch_global('sources', ['file', 'vim-lsp', 'around', 'neosnippet'])
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
                \ 'neosnippet': {
                    \ 'mark': 'ns',
                    \ 'dup': v:true,
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
    " autocmd PlugLocal User ddc.vim call s:ddc_hook()
    autocmd PlugLocal InsertEnter * ++once call s:ddc_hook()
    " }}}
endif

