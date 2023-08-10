" command line と検索時に補完してくれるplugin
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

Plug 'gelguy/wilder.nvim', PlugCond(1, {'do': function('UpdateRemotePlugins'), 'on': []})
call meflib#add('lazy_plugins', 'wilder.nvim')
autocmd PlugLocal User wilder.nvim call s:wilder_hook()

