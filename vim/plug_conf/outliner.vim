" 簡易，柔軟 outliner生成器
Plug 'MeF0504/outliner.vim', PlugCond(1, {'on': 'OutLiner'})
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
                    \ 'pattern': '^@',
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

    let g:outliner_settings.markdown = get(g:outliner_settings, 'markdown', {})
    call extend(g:outliner_settings.markdown, {
                \ 'title': {
                    \ 'pattern': '^\s*#\+\s',
                    \ 'line': 0,
                    \},
                \}, 'keep')

    let g:outliner_settings.tex = get(g:outliner_settings, 'tex', {})
    call extend(g:outliner_settings.tex, {
                \ 'section': {
                    \ 'pattern': '^\s*\\.*section{.*}',
                    \ 'line': 0,
                    \},
                \ 'label': {
                    \ 'pattern': '^\s*\\label{.*}',
                    \ 'line': 0,
                    \},
                \ }, 'keep')

    let g:outliner_settings.fish = get(g:outliner_settings, 'fish', {})
    call extend(g:outliner_settings.fish, {
                \ 'function': {
                    \ 'pattern': '^\s*function\s',
                    \ 'line': 0,
                    \},
                \ 'var': {
                    \ 'pattern': '^\s*set\s',
                    \ 'line': 0,
                    \},
                \ 'alias': {
                    \ 'pattern': '^\s*alias\s',
                    \ 'line': 0,
                    \},
                \}, 'keep')

    let g:outliner_settings.help = get(g:outliner_settings, 'help', {})
    call extend(g:outliner_settings.help, {
                \ 'head1': {
                    \ 'pattern': '^=\+$',
                    \ 'line': 1,
                    \},
                \}, 'keep')
endfunction
autocmd PlugLocal User outliner.vim call s:outliner_hook()
nnoremap <silent> <Leader>o <Cmd>OutLiner<CR>

