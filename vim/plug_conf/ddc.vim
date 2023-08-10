" 新世代(2021) dark deno-powered completion framework
" plugins for ddc.vim
" source
Plug 'Shougo/ddc-around', PlugCond(meflib#get('deno_on', 0))
Plug 'LumaKernel/ddc-file', PlugCond(meflib#get('deno_on', 0))
Plug 'LumaKernel/ddc-tabnine', PlugCond(meflib#get('deno_on', 0))
Plug 'shun/ddc-vim-lsp', PlugCond(meflib#get('deno_on', 0))
" matcher
Plug 'Shougo/ddc-matcher_head', PlugCond(meflib#get('deno_on', 0))
" sorter
Plug 'Shougo/ddc-sorter_rank', PlugCond(meflib#get('deno_on', 0))
" converter
Plug 'Shougo/ddc-converter_remove_overlap', PlugCond(meflib#get('deno_on', 0))
" UI
Plug 'Shougo/ddc-ui-native', PlugCond(meflib#get('deno_on', 0))

Plug 'Shougo/ddc.vim', PlugCond(meflib#get('deno_on', 0))
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
    if meflib#get('tabnine_on', 1)
        let ft_sources = ['vim-lsp', 'around', 'tabnine', 'file']
    else
        let ft_sources = ['vim-lsp', 'around', 'file']
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
if meflib#get('deno_on', 0)
    " autocmd PlugLocal User ddc.vim call s:ddc_hook()
    autocmd PlugLocal InsertEnter * ++once call s:ddc_hook()
endif

