
if has('nvim')
    let s:plug_dir = stdpath('config')..'/plugged'
else
    if has('win32') || has('win64')
        let s:plug_dir = expand('~')..'/vimfiles/plugged'
    else
        let s:plug_dir = expand('~')..'/.vim/plugged'
    endif
endif

augroup PlugLocal
    autocmd!
augroup END

" https://github.com/junegunn/vim-plug/wiki/tips
function! PlugCond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" condition check of loading plugins. {{{
call meflib#set('load_plugin', {})
if exists('*searchcount') && exists('*popup_create')
    call meflib#set('load_plugin', 1, 'hitspop')
endif
if executable('deno')
    if has('patch-8.2.3452') || has('nvim-0.6.0')
        call meflib#set('load_plugin', 1, 'denops')
    endif
endif
if !meflib#get('load_plugin', 0, 'denops')
    if has('python3')
        if v:version>=801 || has('nvim-0.3.0')
            call meflib#set('load_plugin', 1, 'deoplete')
        endif
    endif
endif
" }}}

" stop loading default plugins {{{
" ref: https://lambdalisue.hatenablog.com/entry/2015/12/25/000046
let g:loaded_gzip              = 1
let g:loaded_tar               = 1
let g:loaded_tarPlugin         = 1
let g:loaded_zip               = 1
let g:loaded_zipPlugin         = 1
let g:loaded_rrhelper          = 1
let g:loaded_2html_plugin      = 1
let g:loaded_vimball           = 1
let g:loaded_vimballPlugin     = 1
let g:loaded_getscript         = 1
let g:loaded_getscriptPlugin   = 1
let g:loaded_netrw             = 1
let g:loaded_netrwPlugin       = 1
let g:loaded_netrwSettings     = 1
let g:loaded_netrwFileHandlers = 1
let g:loaded_tutor_mode_plugin = 1
" }}}

let g:insert_plugins = []
call plug#begin(s:plug_dir)

" for doc
Plug 'junegunn/vim-plug'

" Project Sekai inspired plugin
Plug 'MeF0504/untitled.vim', PlugCond(!exists('g:vscode'), {'on': 'Untitled'})

" colorscheme
Plug 'MeF0504/vim-monoTone', PlugCond(!exists('g:vscode'))

" window のresize, 移動用plugin
Plug 'simeji/winresizer', PlugCond(!exists('g:vscode'), {'on': 'WinResizerStartResize'})
" {{{
nnoremap <leader>w <Cmd>WinResizerStartResize<CR>
let g:winresizer_finish_with_escape = 0
let g:winresizer_start_key = '<leader>w'
let g:winresizer_vert_resize = 5
let g:winresizer_horiz_resize = 2
" }}}

" カッコの強調を，処理を落として高速化
" https://itchyny.hatenablog.com/entry/2016/03/30/210000
Plug 'itchyny/vim-parenmatch', PlugCond(!exists('g:vscode'))
" {{{
" デフォルト機能をoff
let g:loaded_matchparen = 1
" デフォルトのhighlightをoff
let g:parenmatch_highlight = 0
" }}}

" color schemes
let s:colorscheme_file = expand('<sfile>:h:h').'/plug_conf/colorscheme.vim'
if !exists('g:vscode') && filereadable(s:colorscheme_file)
    execute 'source '..s:colorscheme_file
endif

" usual (somewhat heavy) plugins
let s:plug_file = expand('<sfile>:h:h').'/plug_conf/vimplug.vim'
if !exists('g:vscode') && filereadable(s:plug_file)
    execute 'source '..s:plug_file
endif

" plugins that also works in VS Code
let s:vscode_file = expand('<sfile>:h:h').'/plug_conf/vs_code.vim'
if filereadable(s:vscode_file)
    execute 'source '..s:vscode_file
endif

call plug#end()

" https://zenn.dev/kawarimidoll/articles/8172a4c29a6653
" 遅延読み込み
function! s:lazy_load(timer) abort
    let lazy_plugins = meflib#get('lazy_plugins', [])
    if !empty(lazy_plugins)
        call plug#load(lazy_plugins)
    endif
endfunction
call timer_start(100, function("s:lazy_load"))

" InsertEnter で読み込み
function! s:insert_load() abort
    let insert_plugins = meflib#get('insert_plugins', [])
    if !empty(insert_plugins)
        call plug#load(insert_plugins)
    endif
endfunction
autocmd PlugLocal InsertEnter * ++once call s:insert_load()

