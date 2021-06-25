
" please :source %

" {{{
let s:highlight_names = [
            \ 'Comment',
            \ 'Constant',
            \ 'String',
            \ 'Character',
            \ 'Number',
            \ 'Boolean',
            \ 'Float',
            \ 'Identifier',
            \ 'Function',
            \ 'Statement',
            \ 'Conditional',
            \ 'Repeat',
            \ 'Label',
            \ 'Operator',
            \ 'Keyword',
            \ 'Exception',
            \ 'PreProc',
            \ 'Include',
            \ 'Define',
            \ 'Macro',
            \ 'PreCondit',
            \ 'Type',
            \ 'StorageClass',
            \ 'Structure',
            \ 'Typedef',
            \ 'Special',
            \ 'SpecialChar',
            \ 'Tag',
            \ 'Delimiter',
            \ 'SpecialComment',
            \ 'Debug',
            \ 'Underlined',
            \ 'Ignore',
            \ 'Error',
            \ 'Todo',
            \ ' ColorColumn',
            \ ' Conceal',
            \ ' Cursor',
            \ ' lCursor',
            \ ' CursorIM',
            \ ' CursorColumn',
            \ ' CursorLine',
            \ ' Directory',
            \ ' DiffAdd',
            \ ' DiffChange',
            \ ' DiffDelete',
            \ ' DiffText',
            \ ' EndOfBuffer',
            \ ' ErrorMsg',
            \ ' VertSplit',
            \ ' Folded',
            \ ' FoldColumn',
            \ ' SignColumn',
            \ ' IncSearch',
            \ ' LineNr',
            \ ' LineNrAbove',
            \ ' LineNrBelow',
            \ ' CursorLineNr',
            \ ' MatchParen',
            \ ' ModeMsg',
            \ ' MoreMsg',
            \ ' NonText',
            \ ' Normal',
            \ ' Pmenu',
            \ ' PmenuSel',
            \ ' PmenuSbar',
            \ ' PmenuThumb',
            \ ' Question',
            \ ' QuickFixLine',
            \ ' Search',
            \ ' SpecialKey',
            \ ' SpellBad',
            \ ' SpellCap',
            \ ' SpellLocal',
            \ ' SpellRare',
            \ ' StatusLine',
            \ ' StatusLineNC',
            \ ' StatusLineTerm',
            \ ' StatusLineTermNC',
            \ ' TabLine',
            \ ' TabLineFill',
            \ ' TabLineSel',
            \ ' Terminal',
            \ ' Title',
            \ ' Visual',
            \ ' VisualNOS',
            \ ' WarningMsg',
            \ ' WildMenu',
            \ ]
" }}}

for s:sn in s:highlight_names
    execute 'syntax keyword '.s:sn.' containedin=ALL '.s:sn
endfor
