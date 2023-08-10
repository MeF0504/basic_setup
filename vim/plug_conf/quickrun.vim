" コード実行plugin
Plug 'thinca/vim-quickrun', PlugCond(1, {'on': 'QuickRun'})
let s:quickrun_status = "%#StatusLine_CHK#%{quickrun#is_running()?'>...':''}%#StatusLine#"
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
        \ 'runner/terminal/opener' : 'botright new',
        \ 'hook/time/enable'        : 1,
        \ 'hook/time/dest'        : "buffer",
        \ },
        \ 'keep')
    if has('terminal')
        let g:quickrun_config._.runner = 'terminal'
        let cur_status = meflib#get('statusline', '_', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]")
        call meflib#set('statusline', '_', cur_status..s:quickrun_status)
    elseif has('job')
        let g:quickrun_config._.runner = 'job'
        let cur_status = meflib#get('statusline', '_', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]")
        call meflib#set('statusline', '_', cur_status..s:quickrun_status)
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
    if &filetype ==# 'vim'
        echomsg 'source %'
        source %
    else
        QuickRun
    endif
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

" job runner of quickrun for Neovim (unofficial)
Plug 'lambdalisue/vim-quickrun-neovim-job', PlugCond(has('nvim'))
function! s:quickrun_nvim_job_hook() abort
    if !meflib#get('quickrun_nvimterm', 1)
        " 変数がなければ初期化
        let g:quickrun_config = get(g:, 'quickrun_config', {})
        let g:quickrun_config._ = get(g:quickrun_config, '_', {})
        let g:quickrun_config._.runner = 'neovim_job'
        let cur_status = meflib#get('statusline', '_', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]")
        call meflib#set('statusline', '_', cur_status..s:quickrun_status)
    endif
endfunction
" plugin directoryが無いとlazy loadはされないらしい。それもそうか。
autocmd PlugLocal User vim-quickrun if has('nvim') | call s:quickrun_nvim_job_hook() | endif

" terminal runner of quickrun for Neovim (unofficial)
Plug 'statiolake/vim-quickrun-runner-nvimterm', PlugCond(has('nvim'))
function! s:quickrun_nvimterm_hook() abort
    if meflib#get('quickrun_nvimterm', 1)
        " 変数がなければ初期化
        let g:quickrun_config = get(g:, 'quickrun_config', {})
        let g:quickrun_config._ = get(g:quickrun_config, '_', {})
        call extend(g:quickrun_config._,
                    \ {
                    \ 'runner': 'nvimterm',
                    \ 'runner/nvimterm/opener': 'botright new',
                    \ }, "force")
        let cur_status = meflib#get('statusline', '_', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]")
        call meflib#set('statusline', '_', cur_status..s:quickrun_status)
    endif
endfunction
autocmd PlugLocal User vim-quickrun if has('nvim') | call s:quickrun_nvimterm_hook() | endif

