
if has('nvim')
    let s:plug_dir = stdpath('config')..'/plugged'
else
    if has('win32') || has('win64')
        let s:plug_dir = expand('~')..'/vimfiles/plugged'
    else
        let s:plug_dir = expand('~')..'/.vim/plugged'
    endif
endif
if &runtimepath !~# '/vim-plug'
    execute 'set runtimepath+='..substitute(s:plug_dir, ' ', '\\ ', 'g')
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
call meflib#set_local_var('load_plugin', {})
if exists('*searchcount') && exists('*popup_create')
    call meflib#set_local_var('load_plugin', 1, 'hitspop')
endif
if executable('deno')
    if has('patch-8.2.3452') || has('nvim-0.6.0')
        call meflib#set_local_var('load_plugin', 1, 'denops')
    endif
endif
if !meflib#get_local_var('load_plugin', 0, 'denops')
    if has('python3')
        if v:version>=801 || has('nvim-0.3.0')
            call meflib#set_local_var('load_plugin', 1, 'deoplete')
        endif
    endif
endif
" }}}

call plug#begin(s:plug_dir)

" for doc
Plug 'junegunn/vim-plug'

" Project Sekai inspired plugin
Plug 'MeF0504/untitled.vim', PlugCond(1, {'on': 'Untitled'})

" vim plugin like chrome://dino
Plug 'MeF0504/dino.vim', PlugCond(1, {'on': 'Dino'})

" colorscheme
Plug 'MeF0504/vim-monoTone'

" window のresize, 移動用plugin
Plug 'simeji/winresizer'
" {{{
let g:winresizer_finish_with_escape = 0
let g:winresizer_start_key = '<leader>w'
let g:winresizer_vert_resize = 5
let g:winresizer_horiz_resize = 2
" }}}

" カッコの強調を，処理を落として高速化
" https://itchyny.hatenablog.com/entry/2016/03/30/210000
Plug 'itchyny/vim-parenmatch'
" {{{
" デフォルト機能をoff
let g:loaded_matchparen = 1
" デフォルトのhighlightをoff
let g:parenmatch_highlight = 0
" }}}

" color schemes
let s:colorscheme_file = expand('<sfile>:h:h').'/vimplug/colorscheme.vim'
if filereadable(s:colorscheme_file)
    execute 'source '..s:colorscheme_file
endif

" usual (somewhat heavy) plugins
let s:plug_file = expand('<sfile>:h:h').'/vimplug/vimplug.vim'
if filereadable(s:plug_file)
    execute 'source '..s:plug_file
endif

call plug#end()

