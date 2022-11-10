
Plug 'MeF0504/ColorSchemePreview.vim'

Plug 'MeF0504/vim-shiki'
" shiki {{{
function! <SID>my_color_set_shiki()
    highlight Directory ctermfg=34 guifg=#00af00
endfunction
call meflib#set('my_color_set', 'shiki', expand('<SID>').'my_color_set_shiki')
" }}}

Plug 'altercation/vim-colors-solarized'

Plug 'NLKNguyen/papercolor-theme'
" PaperColor {{{
let g:PaperColor_Theme_Options = {
            \ 'theme': {
                \ 'default': {
                    \ 'transparent_background': 0,
                \ },
            \ },
            \ 'language': {
                \ 'python': {
                    \ 'highlight_builtins': 1,
                \ },
            \ },
        \ }
function! <SID>my_color_set_PaperColor()
    highlight Search ctermbg=36 guibg=#00af87
    highlight SpecialKey cterm=Underline ctermfg=245 ctermbg=233 gui=Underline guifg=#8a8a8a guibg=#121212
    " overwrite
    if &background == 'dark'
        highlight IndentGuidesOdd ctermfg=17 ctermbg=17 guifg=#003851 guibg=#003851
        highlight IndentGuidesEven ctermfg=54 ctermbg=54 guifg=#3f0057 guibg=#3f0057
    else
        highlight IndentGuidesOdd ctermfg=159 ctermbg=159 guifg=#e0f8ff guibg=#e0f8ff
        highlight IndentGuidesEven ctermfg=225 ctermbg=225 guifg=#ffe0fd guibg=#ffe0fd
    endif
endfunction
call meflib#set('my_color_set', 'PaperColor', expand('<SID>').'my_color_set_PaperColor')
" }}}

Plug 'google/vim-colorscheme-primary'
" primary {{{
function! <SID>my_color_set_primary()
    highlight Normal ctermfg=254 guifg=#e4e4e4
    highlight Identifier ctermbg=None guibg=NONE
    " highlight String ctermbg=None
    highlight PreProc ctermbg=None guibg=NONE
    highlight Function ctermbg=None guibg=NONE
    highlight Statement ctermbg=None guibg=NONE
    highlight Number ctermbg=None guibg=NONE
    highlight Comment ctermbg=None guibg=NONE
    highlight Keyword ctermbg=None guibg=NONE
    highlight Conditional ctermbg=None guibg=NONE
    highlight Operator ctermbg=None guibg=NONE
    highlight Repeat ctermbg=None guibg=NONE
    highlight Exception ctermbg=None guibg=NONE
    highlight Type ctermbg=None guibg=NONE
    highlight Structure ctermbg=None guibg=NONE
    highlight Macro ctermbg=None guibg=NONE
    highlight SpecialKey ctermfg=242 ctermbg=None guifg=#6c6c6c guibg=NONE
    highlight CursorWord1 ctermbg=239 cterm=None guibg=#4e4e4e gui=NONE
endfunction
call meflib#set('my_color_set', 'primary', expand('<SID>').'my_color_set_primary')
" }}}

Plug 'haishanh/night-owl.vim'
" night-owl {{{
function! <SID>my_color_set_night_owl()
    highlight Pmenu ctermfg=7
    highlight Quote ctermfg=37 guifg=#00d7d7
    highlight Comment ctermfg=243 ctermbg=233 guifg=#637777 guibg=#011627 cterm=NONE
    highlight shComment ctermfg=243 ctermbg=233 guifg=#637777 guibg=#011627 cterm=NONE
    highlight SpecialKey ctermbg=235 guibg=#202020
    highlight Number ctermfg=162 guifg=#c02a8f
    highlight Todo ctermfg=17 ctermbg=228 cterm=BOLD guifg=#101060 guibg=#f8fa6a gui=BOLD
    highlight LineNr ctermfg=240 guifg=#535353
    highlight EndOfBuffer ctermbg=bg guibg=bg

    highlight HiTagImports ctermfg=227 guifg=#f0e860
endfunction
call meflib#set('my_color_set', 'night_owl', expand('<SID>').'my_color_set_night_owl')
" }}}

Plug 'MeF0504/inkpotter.vim'
" inkpotter {{{
function! <SID>my_color_set_inkpotter()
    highlight CursorWord1 ctermbg=235 cterm=None guibg=#262626 gui=NONE
    highlight Quote ctermfg=183 ctermbg=None guifg=#d7afff guibg=NONE

    highlight HiTagImports ctermfg=225 guifg=#f0b7f0
endfunction
call meflib#set('my_color_set', 'inkpotter', expand('<SID>').'my_color_set_inkpotter')
" }}}

Plug 'ulwlu/elly.vim'

Plug 'chasinglogic/modus-themes-vim'
" modus {{{
function! <SID>my_color_set_modus_operandi() abort
    " ctermがない？
    set background=light
    highlight DiffDelete gui=Bold guifg=#939393 guibg=#e0ffff
    highlight SpecialKey gui=None guifg=#101010 guibg=#cacaca
    highlight ErrorMsg gui=Bold guifg=#000000 guibg=#a80000
    highlight WarningMsg gui=Bold guifg=#000000 guibg=#909000
    highlight Folded gui=None guifg=#3d3d3d guibg=#f5dad0
    highlight HiTagImports guifg=#006a00
    highlight Special gui=None guifg=#252525 guibg=#dfc4ff
    highlight CursorLineNr guifg=#a00060
    highlight Comment guifg=#858585
    highlight CursorWord1 guibg=#e5fce5
    highlight IncSearch cterm=None gui=NONE guifg=NONE guibg=#ae54fc
    highlight TJSelect guibg=#c0e8ff guifg=#000000
    highlight Title gui=Bold guifg=#580030
    highlight LspWarningText guifg=#ffff00 guibg=Gray
endfunction
call meflib#set('my_color_set', 'modus_operandi', expand('<SID>').'my_color_set_modus_operandi')
" }}}

Plug 'sainnhe/everforest'

Plug 'thedenisnikulin/vim-cyberpunk'
" silverhand {{{
function! <SID>my_color_set_silverhand() abort
    highlight link HiTagFunctions Function
    highlight Visual guifg=#c500e5 guibg=#19213b
    highlight HiTagImports guifg=#a0eaff
    highlight IndentGuidesEven guifg=#8a50bf guibg=#8a50bf
    highlight IndentGuidesOdd guifg=#00a5be guibg=#00a5be
endfunction
call meflib#set('my_color_set', 'silverhand', expand('<SID>').'my_color_set_silverhand')
" }}}

