
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

" extensions of Plug command {{{
" https://github.com/junegunn/vim-plug/wiki/tips
function! PlugCond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

function! PlugLoadChk(plug_name) abort
    let unload_plugs = meflib#get('unload_plugins', [])
    if match(unload_plugs, printf("^%s$", a:plug_name)) != -1
        return v:false
    else
        return v:true
    endif
endfunction

function! s:plug_wrapper(plug_name, ...) abort
    if PlugLoadChk(a:plug_name)
        let opt = a:000
    else
        " echomsg "unload "..a:plug_name
        let opt = [{'on': [], 'for': []}]
    endif
    call call('plug#', [a:plug_name]+opt)
endfunction

command! -nargs=+ PlugWrapper call s:plug_wrapper(<args>)
" }}}

" condition check of loading plugins. {{{
if exists('*searchcount') && exists('*popup_create')
    call meflib#add('unload_plugins', 'osyo-manga/vim-anzu')
else
    call meflib#add('unload_plugins', 'obcat/vim-hitspop')
endif
if executable('deno')
    if has('patch-8.2.3452') || has('nvim-0.6.0')
        call meflib#set('plug_opt', 'denops', 1)
    endif
endif
if !meflib#get('plug_opt', 'denops', 0)
    if has('python3')
        if v:version>=801 || has('nvim-0.3.0')
            call meflib#set('plug_opt', 'deoplete', 1)
        endif
    endif
endif
" }}}

" stop loading default plugins {{{
" ref: https://lambdalisue.hatenablog.com/entry/2015/12/25/000046
let s:ftext = expand('%:e:e:e')
if match(s:ftext, 'gz') == -1
    let g:loaded_gzip = 1
endif
if match(s:ftext, 't[agx][rz]') == -1
    let g:loaded_tar = 1
    let g:loaded_tarPlugin = 1
endif
if match(s:ftext, 'zip') == -1
    let g:loaded_zip = 1
    let g:loaded_zipPlugin = 1
endif
let g:loaded_rrhelper = 1
let g:loaded_2html_plugin = 1
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1
let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1
let g:loaded_netrwFileHandlers = 1
let g:loaded_tutor_mode_plugin = 1
" }}}

let g:plug_window = 'tab new'
call plug#begin(s:plug_dir)

" for doc
PlugWrapper 'junegunn/vim-plug'

" colorscheme
PlugWrapper 'MeF0504/vim-monoTone'

" カッコの強調を，処理を落として高速化
" https://itchyny.hatenablog.com/entry/2016/03/30/210000
PlugWrapper 'itchyny/vim-parenmatch'
" {{{
" デフォルト機能をoff
let g:loaded_matchparen = 1
" デフォルトのhighlightをoff
let g:parenmatch_highlight = 0
" highlights
function! <SID>parenmatch_his() abort
    highlight link ParenMatch MatchParen
endfunction
call meflib#add('plugin_his', expand('<SID>').'parenmatch_his')
" }}}

" readme をhelpとして見れるようにする
let g:readme_viewer#plugin_manager = 'vim-plug'
PlugWrapper '4513ECHO/vim-readme-viewer', PlugCond(1, { 'on': 'PlugReadme' })

" vim上でpetを飼う
PlugWrapper 'MeF0504/vim-pets', PlugCond(1, {'on': ['Pets', 'PetsWithYou']})
" {{{ vim-pets
function! s:pets_hook() abort
    let g:pets_garden_pos = [&lines-&cmdheight-2, &columns, 'botright']
    let g:pets_lifetime_enable = 0
    let g:pets_birth_enable = 1
endfunction
autocmd PlugLocal User vim-pets call s:pets_hook()
" }}}

" color schemes
let s:colorscheme_file = expand('<sfile>:h:h').'/plug_conf/colorscheme.vim'
if filereadable(s:colorscheme_file)
    execute 'source '..s:colorscheme_file
endif

" usual (somewhat heavy) plugins
let s:plug_files = glob(expand('<sfile>:h:h').'/plug_conf/*.vim', 0, 1)
for s:plug_file in s:plug_files
    if s:plug_file ==# s:colorscheme_file
        continue
    endif
    if filereadable(s:plug_file)
        execute 'source '..s:plug_file
    endif
endfor

call plug#end()

function! s:load_comp(arglead, cmdline, cursorpos) abort
    let dirs = getcompletion(s:plug_dir..'/', 'dir')
    let dirs = map(dirs, "fnamemodify(v:val[:-2], ':t')")
    return filter(dirs, '!stridx(v:val, a:arglead)')
endfunction
command -nargs=1 -complete=customlist,s:load_comp PlugLoad call plug#load(<f-args>)

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

