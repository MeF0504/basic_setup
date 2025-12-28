" Dark deno-powered hexadecimal plugin for Vim/Neovim
" https://zenn.dev/shougo/articles/ddx-vim-beta

if !meflib#get('plug_opt', 'denops', 0)
    call meflib#add('unload_plugins', 'Shougo/ddx.vim')
    call meflib#add('unload_plugins', 'Shougo/ddx-commands.vim')
    call meflib#add('unload_plugins', 'Shougo/ddx-analyzer-zip')
    call meflib#add('unload_plugins', 'Shougo/ddx-ui-hex')
endif

PlugWrapper 'Shougo/ddx.vim'
PlugWrapper 'Shougo/ddx-commands.vim'
PlugWrapper 'Shougo/ddx-analyzer-zip'
PlugWrapper 'Shougo/ddx-ui-hex'

function! s:ddx_hook() abort
    call ddx#custom#patch_global({
                \   'ui': 'hex',
                \   'analyzers': ['zip'],
                \ })
    " ↓ run in Ddx command?
    " call ddx#start()
endfunction

if meflib#get('plug_opt', 'denops', 0)
    autocmd PlugLocal VimEnter * ++once call s:ddx_hook()
endif

autocmd FileType ddx-hex call s:ddx_my_settings()
function! s:ddx_my_settings() abort
  nnoremap <buffer> q
              \ <Cmd>call ddx#ui#hex#do_action('quit')<CR>
  nnoremap <buffer> r
              \ <Cmd>call ddx#ui#hex#do_action('change')<CR>
  nnoremap <buffer> i
              \ <Cmd>call ddx#ui#hex#do_action('insert')<CR>
  nnoremap <buffer> x
              \ <Cmd>call ddx#ui#hex#do_action('remove')<CR>
  nnoremap <buffer> S
              \ <Cmd>call ddx#ui#hex#do_action('save')<CR>
  nnoremap <buffer> u
              \ <Cmd>call ddx#ui#hex#do_action('undo')<CR>
endfunction
