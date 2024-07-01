" Filer
" fern plugins
PlugWrapper 'lambdalisue/fern-hijack.vim'

PlugWrapper 'lambdalisue/fern-ssh', PlugCond(1, {'on': 'Fern'})
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

PlugWrapper 'lambdalisue/fern-mapping-project-top.vim', PlugCond(1, {'on': 'Fern'})

PlugWrapper 'MeF0504/fern-mapping-search-ctrlp.vim', PlugCond(1, {'on': 'Fern'})
" {{{
let g:fern_search_ctrlp_root = 1
" }}}

PlugWrapper 'lambdalisue/fern-renderer-nerdfont.vim', PlugCond(1, {'on': 'Fern'})
" fern-nerd-font {{{
function! s:fern_renderer_nerdfont() abort
    if meflib#get('plug_opt', 'nerdfont', 0)
        let g:fern#renderer = "nerdfont"
    else
        let g:fern#renderer = "default"
    endif
    let g:fern#renderer#nerdfont#indent_markers = 1
endfunction
autocmd PlugLocal User fern-renderer-nerdfont.vim call s:fern_renderer_nerdfont()
" }}}

PlugWrapper 'lambdalisue/fern-git-status.vim', PlugCond(1, {'on': 'Fern'})
" fern git status {{{
" 遅延loadするので
let g:fern_git_status_disable_startup = 0
let g:fern_git_status#disable_directories = 1
function! s:fern_git_status_hook() abort
    call fern_git_status#init()
endfunction
autocmd PlugLocal User fern-git-status.vim call s:fern_git_status_hook()
" }}}
" }}}

PlugWrapper 'lambdalisue/fern.vim', PlugCond(1, {'on': 'Fern'})
"" Fern {{{
" default keymap off
let g:fern#disable_default_mappings = 1
" width
let g:fern#drawer_width = meflib#get('side_width', 30)
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
call meflib#add('plugin_his', expand('<SID>').'fern_his')

function! s:fern_hook() abort
    call add(g:fern#scheme#file#mapping#mappings, 'aftviewer')
endfunction
autocmd PlugLocal User fern.vim call s:fern_hook()
autocmd PlugLocal FileType fern setlocal nonumber
"" }}}

