" vim script encoding setting
scriptencoding utf-8
"" vim dein (plugin manager) setting

if &compatible
    set nocompatible               " Be iMproved
endif

augroup deinLocal
    autocmd!
augroup END

if !exists("$XDG_CONFIG_HOME")
    let $XDG_CONFIG_HOME = expand("~/.config")
endif

let s:vim_dir = meflib#basic#get_conf_dir()
let s:dein_dir = s:vim_dir. 'dein/'

let s:light_file = s:vim_dir . 'toml/dein_min.toml'
let s:toml_file  = s:vim_dir . 'toml/dein.toml'
let s:color_file = s:vim_dir . 'toml/dein_colorscheme.toml'
let s:lazy_file  = s:vim_dir . 'toml/dein_lazy.toml'

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

" update the settings referring to https://knowledge.sakura.ad.jp/23248/
" Required: dein install check
let s:dein_path = s:dein_dir.."repos/github.com/Shougo/dein.vim"
if !isdirectory(s:dein_path)
    echohl ErrorMsg
    echomsg printf('dein directory %s not found.', s:dein_path)
    echohl None
    finish
endif

if &runtimepath !~# '/dein.vim'
    execute "set runtimepath+="..s:dein_path
endif

" Required: begin settings
if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    " Let dein manage dein
    " Required:
    call dein#add('Shougo/dein.vim')
    " update
    " :call dein#update()
    " 何かおかしいとき
    " :call dein#recache_runtimepath()

    " Add or remove your plugins here:

    " You can specify revision/branch/tag.
    " call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

    if filereadable(s:light_file)
        call dein#load_toml(s:light_file, {'lazy':0})
    endif
    if filereadable(s:toml_file)
        call dein#load_toml(s:toml_file, {'lazy':0})
    endif
    if filereadable(s:color_file)
        call dein#load_toml(s:color_file, {'lazy':0})
    endif
    if filereadable(s:lazy_file)
        call dein#load_toml(s:lazy_file, {'lazy':1})
    endif

    " Required:
    call dein#end()
    call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
    call dein#install()
endif

" show the status of dein in statusline.
let s:dein_status = "%#StatusLine_CHK#%{empty(dein#get_progress())?'':'^...'}%#StatusLine#"
let s:cur_status = meflib#get_local_var('statusline', "%f%m%r%h%w%<%=%y\ %l/%L\ [%P]", '_')
call meflib#set_local_var('statusline', s:cur_status..s:dein_status, '_')

" Plugin remove check
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
    function! s:RemovePlugins()
        " call map(s:removed_plugins, "delete(v:val, 'rf')")
        for s:rmp in s:removed_plugins
            let yn = input('remove '.s:rmp.'? (y/[n])')
            if yn=='y'
                call delete(s:rmp, 'rf')
            endif
        endfor
        call dein#recache_runtimepath()
    endfunction
    autocmd deinLocal VimEnter * ++once call s:RemovePlugins()
endif

autocmd deinLocal VimEnter * ++once call dein#call_hook('post_source')

