"vim script encording setting
scriptencoding utf-8
if &compatible
  set nocompatible               " Be iMproved
endif

augroup deinLocal
    autocmd!
augroup END

if !exists("$XDG_CONFIG_HOME")
    let $XDG_CONFIG_HOME = expand("~/.config")
endif

if has('win32')
    let s:dein_dir = expand("~/vimfiles/")
else
    let s:dein_dir = $XDG_CONFIG_HOME . '/nvim/'
endif

let s:toml_file = s:dein_dir . '/toml/dein.toml'
let s:lazy_file = s:dein_dir . '/toml/dein_lazy.toml'

" update the settings reffering to https://knowledge.sakura.ad.jp/23248/
" Required: dein install check
if &runtimepath !~# '/dein.vim'
    execute "set runtimepath+=" . s:dein_dir . "/dein/repos/github.com/Shougo/dein.vim"
endif

" Required: begin settings
if dein#load_state(s:dein_dir . '/dein/')
  call dein#begin(s:dein_dir . '/dein/')

  call dein#load_toml(s:toml_file, {'lazy':0})
  call dein#load_toml(s:lazy_file, {'lazy':1})

  " Let dein manage dein
  " Required:
  "call dein#add('Shougo/dein.vim')

  " Add or remove your plugins here:

  " You can specify revision/branch/tag.
  "call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

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

" Plugin remove check
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
    " call map(s:removed_plugins, "delete(v:val, 'rf')")
    for s:rmp in s:removed_plugins
        let yn = input('remove '.s:rmp.'? (y/[n])')
        if yn=='y'
            call delete(s:rmp, 'rf')
        endif
    endfor
    call dein#recache_runtimepath()
endif

