" 新世代(2021) dark deno-powered completion framework
if !meflib#get('plug_opt', 'denops', 0)
    call meflib#add('unload_plugins', 'Shougo/ddc.vim')
    call meflib#add('unload_plugins', 'Shougo/ddc-around')
    call meflib#add('unload_plugins', 'LumaKernel/ddc-file')
    call meflib#add('unload_plugins', 'LumaKernel/ddc-tabnine')
    call meflib#add('unload_plugins', 'shun/ddc-vim-lsp')
    call meflib#add('unload_plugins', 'Shougo/ddc-matcher_head')
    call meflib#add('unload_plugins', 'Shougo/ddc-sorter_rank')
    call meflib#add('unload_plugins', 'Shougo/ddc-converter_remove_overlap')
    call meflib#add('unload_plugins', 'Shougo/ddc-ui-native')
endif
" plugins for ddc.vim
" source
PlugWrapper 'Shougo/ddc-around'
PlugWrapper 'LumaKernel/ddc-file'
PlugWrapper 'LumaKernel/ddc-tabnine'
PlugWrapper 'shun/ddc-vim-lsp'
" matcher
PlugWrapper 'Shougo/ddc-matcher_head'
" sorter
PlugWrapper 'Shougo/ddc-sorter_rank'
" converter
PlugWrapper 'Shougo/ddc-converter_remove_overlap'
" UI
PlugWrapper 'Shougo/ddc-ui-native'

PlugWrapper 'Shougo/ddc.vim'
function! s:ddc_hook() abort
    echomsg 'ddc setting start'
    " set UI
    call ddc#custom#patch_global('ui', 'native')
    " add sources
    call ddc#custom#patch_global('sources', ['vim-lsp', 'around', 'file'])
    " set basic options
    call ddc#custom#patch_global(
        \ 'sourceOptions', {
            \ '_': {
                \ 'matchers': ['matcher_head'],
                \ 'sorters': ['sorter_rank'],
                \ 'converters': ['converter_remove_overlap'],
            \ },
        \ })

    " set sorce-specific options
    call ddc#custom#patch_global(
        \ 'sourceOptions', {
            \ 'around': {
                \ 'mark': 'A',
            \ },
            \ 'file': {
                \ 'mark': 'F',
                \ 'isVolatile': v:true,
                \ 'forceCompletionPattern': '\S/\S*',
            \ },
            \ 'tabnine': {
                \ 'mark': 'TN',
                \ 'maxItems': 5,
                \ 'isVolatile': v:true,
            \ },
            \ 'vim-lsp': {
                \ 'mark': 'lsp',
            \ },
        \ })
    call ddc#custom#patch_global(
        \ 'sourceParams', {
            \ 'tabnine': {
                \ 'maxNumResults': 10,
                \ 'storageDir': expand('~/.cache/ddc-tabline'),
            \ },
        \ }
    \ )
    " storageDir doesn't work??

    " set filetype-specific options
    call ddc#custom#patch_filetype(['ps1', 'dosbatch', 'autohotkey', 'registry'], {
        \ 'sourceOptions': {
            \ 'file': {
                \ 'forceCompletionPattern': '\S\\\S*',
            \ },
        \ },
        \ 'sourceParams': {
            \ 'file': {
                \ 'mode': 'win32',
            \ },
        \ }
    \ })
    call ddc#custom#patch_filetype(['vim', 'toml'], {
        \ 'sources': ['necovim', 'around', 'file'],
        \ 'sourceOptions': {
            \ 'necovim': {
                \ 'mark': 'vim',
                \ 'maxItems': 5,
            \},
        \}
    \ })
    let ft_sources = []
    if PlugLoadChk('shun/ddc-vim-lsp')
        call add(ft_sources, 'vim-lsp')
    endif
    if PlugLoadChk('Shougo/ddc-around')
        call add(ft_sources, 'around')
    endif
    if PlugLoadChk('LumaKernel/ddc-tabnine')
        call add(ft_sources, 'tabnine')
    endif
    if PlugLoadChk('LumaKernel/ddc-file')
        call add(ft_sources, 'file')
    endif
    call ddc#custom#patch_filetype(['python', 'c', 'cpp'], {
        \ 'sources': ft_sources,
    \ })

    " Mappings
    " <TAB>: completion.
    inoremap <silent><expr> <TAB>
    \ pumvisible() ? '<C-n>' :
    \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
    \ '<TAB>' : ddc#map#manual_complete()
    " <S-TAB>: completion back.
    inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

    " automatically close preview window.
    autocmd PlugLocal CompleteDone * silent! pclose!

    " on.
    call ddc#enable()

    echomsg 'ddc setting finish'
endfunction
if meflib#get('plug_opt', 'denops', 0)
    " autocmd PlugLocal User ddc.vim call s:ddc_hook()
    autocmd PlugLocal InsertEnter * ++once call s:ddc_hook()
endif

