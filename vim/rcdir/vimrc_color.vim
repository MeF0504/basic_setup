" vim script encoding setting
scriptencoding utf-8
"" vim color settings

" DOC OPTIONS my_color_set
" function to be called for each color scheme.
" DOCEND
" DOC OPTIONS plugin_his
" functions to be called when highlight is set.
" DOCEND
" DOC OPTIONS colorscheme
" colorscheme name to be set. default is 'evening'.
" DOCEND

" Anywhere SID.
function! s:SID_PREFIX() " tentative
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
if empty(expand('<SID>'))
    let s:sid = s:SID_PREFIX()
else
    let s:sid = expand('<SID>')
endif

function! <SID>my_color_set_inkpot()
    highlight Identifier ctermfg=110 guifg=#87afd7
    highlight Number ctermfg=9 guifg=Red
    highlight Type ctermfg=149 guifg=#afd75f
    highlight String ctermfg=222 ctermbg=None guifg=#ffd787 guibg=NONE
    highlight Comment ctermfg=66 guifg=#5f8787 gui=italic
    highlight LineNr ctermfg=243 guifg=#767676
    highlight Title ctermfg=197 guifg=#ff005f
    highlight PreProc ctermfg=35 guifg=#00af5f
    highlight SpecialKey cterm=bold ctermfg=243 ctermbg=233 gui=Bold guifg=#121212
    highlight Normal ctermfg=255 guifg=#eeeeee
    highlight PmenuThumb ctermbg=55 guibg=#5f00af
    highlight MatchParen ctermfg=14 ctermbg=18 cterm=Bold guifg=Aqua guibg=DarkBlue gui=Bold

    highlight CursorWord1 ctermbg=235 cterm=None guibg=#262626 gui=NONE
    highlight Quote ctermfg=183 ctermbg=None guifg=#d7afff guibg=NONE
endfunction
call meflib#set('my_color_set', 'inkpot', s:sid.'my_color_set_inkpot')

function! <SID>my_color_set_evening()
    highlight Normal ctermbg=233 guibg=#121212
        highlight DiffAdd ctermfg=15 ctermbg=4 guifg=White guibg=DarkBlue
        highlight DiffChange ctermfg=15 ctermbg=5 guifg=White guibg=DarkMagenta
        highlight DiffDelete ctermfg=15 ctermbg=6 guifg=White guibg=DarkCyan
        highlight DiffText ctermfg=15 ctermbg=9 guifg=White guibg=Red
endfunction
" ['my_color_set', colors_name, func_name]
call meflib#set('my_color_set', 'evening', s:sid.'my_color_set_evening')

function! <SID>my_color_set()
    " colorscheme specified setings
    let colname = g:colors_name
    let local_scheme_funcs = meflib#get('my_color_set', {})
    if has_key(local_scheme_funcs, colname)
        call call(local_scheme_funcs[colname], [])
    else
        " echo "color scheme: " . g:colors_name
    endif

    """ general settings
    " link {{{
    highlight link VimFunction Function
    highlight link vimIsCommand SpecialChar
    highlight link keepend Special
    if has('nvim')
        highlight link Whitespace SpecialKey
    endif
    " }}}

    " corsor line {{{
    highlight default CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=15 gui=Underline guifg=#00005f guibg=White
    highlight CursorLine cterm=underline ctermfg=None ctermbg=None gui=Underline guifg=NONE guibg=NONE
    " }}}

    " tab line {{{
    if &background == 'dark'
        highlight TabLine cterm=None ctermfg=248 ctermbg=16 guifg=#a8a8a8 guibg=#000000
        highlight TabLineSel cterm=Bold,underline ctermfg=15 ctermbg=243 gui=Bold,Underline guifg=White guibg=#767676
        highlight TabLineFill cterm=Bold ctermfg=45 ctermbg=16 gui=Bold guifg=#00d7ff guibg=#000000
        highlight TabLineDir cterm=Bold ctermfg=24 ctermbg=250 gui=Bold guifg=#005f87 guibg=#bcbcbc
    else
        highlight TabLine cterm=None ctermfg=236 ctermbg=81 guifg=#303030 guibg=#84cafa
        highlight TabLineSel cterm=Bold,underline ctermfg=16 ctermbg=253 gui=Bold,Underline guifg=Black guibg=#dadada
        highlight TabLineFill cterm=Bold ctermfg=20 ctermbg=159 gui=Bold guifg=#0000f0 guibg=#a5f0ff
        highlight TabLineDir cterm=Bold ctermfg=191 ctermbg=24 gui=Bold guifg=#e0f377 guibg=#00538f
    endif
    " }}}

    " 全角スペース表示 {{{
    highlight ZenkakuSpace cterm=None ctermfg=None ctermbg=241 gui=NONE guifg=NONE guibg=#626262
    " }}}

    " statusline color setting {{{
    if exists('*strftime')
        " day-by-day StatusLine Color
        call <SID>Day_by_Day_StatusLine()
    else
        highlight StatusLine cterm=bold ctermfg=234 ctermbg=75 gui=Bold guifg=#1c1c1c guibg=#5fafff
        if !has('nvim')
            highlight StatusLineTerm cterm=bold ctermfg=233 ctermbg=46 gui=Bold guifg=#121212 guibg=#00ff00
        endif
    endif

    " test setting
    highlight StatusLineNC cterm=underline ctermfg=244 ctermbg=None gui=Underline guifg=#808080 guibg=NONE
    " highlight StatusLineNC cterm=underline ctermfg=244 ctermbg=232 gui=Underline guifg=#808080 guibg=#080808
    if !has('nvim')
        highlight StatusLineTermNC cterm=None ctermfg=233 ctermbg=249 gui=NONE guifg=#121212 guibg=#b2b2b2
    endif

    if &background == 'dark'
        highlight StatusLine_ST cterm=None ctermfg=10 ctermbg=236 gui=NONE guifg=#00FF00 guibg=#333333
        highlight StatusLine_FT cterm=bold ctermfg=253 ctermbg=17 gui=Bold guifg=#dadada guibg=#00005f
        highlight StatusLine_FF cterm=bold ctermfg=253 ctermbg=88 gui=Bold guifg=#dadada guibg=#870000
        highlight StatusLine_LN cterm=bold ctermfg=253 ctermbg=29 gui=Bold guifg=#dadada guibg=#00875f
        highlight StatusLine_CHK cterm=bold ctermfg=233 ctermbg=190 gui=Bold guifg=#121212 guibg=#d7ff00
        highlight StatusLine_OFF cterm=Underline ctermfg=254 ctermbg=232 gui=Underline guifg=#eaeaea guibg=#080808
    else
        highlight StatusLine_ST cterm=None ctermfg=29 ctermbg=253 gui=NONE guifg=#008050 guibg=#dddddd
        highlight StatusLine_FT cterm=bold ctermfg=236 ctermbg=68 gui=Bold guifg=#303030 guibg=#73a9ff
        highlight StatusLine_FF cterm=bold ctermfg=236 ctermbg=210 gui=Bold guifg=#303030 guibg=#ffa0a0
        highlight StatusLine_LN cterm=bold ctermfg=236 ctermbg=119 gui=Bold guifg=#303030 guibg=#70ff80
        highlight StatusLine_CHK cterm=bold ctermfg=233 ctermbg=190 gui=Bold guifg=#121212 guibg=#d7ff00
        highlight StatusLine_OFF cterm=Underline ctermfg=233 ctermbg=255 gui=Underline guifg=#101010 guibg=#eeeeee
    endif
    highlight Mode_N cterm=bold ctermfg=253 ctermbg=0 gui=Bold guifg=#dadada guibg=Black
    highlight Mode_Ns cterm=None ctermfg=0 gui=None guifg=Black
    highlight Mode_I cterm=bold ctermfg=253 ctermbg=9 gui=Bold guifg=#dadada guibg=Red
    highlight Mode_Is cterm=None ctermfg=9 gui=None guifg=Red
    highlight Mode_V cterm=bold ctermfg=253 ctermbg=13 gui=Bold guifg=#dadada guibg=Fuchsia
    highlight Mode_Vs cterm=None ctermfg=13 gui=None guifg=Fuchsia
    highlight Mode_R cterm=bold ctermfg=234 ctermbg=3 gui=Bold guifg=#1c1c1c guibg=Olive
    highlight Mode_Rs cterm=None ctermfg=3 gui=None guifg=Olive
    highlight Mode_T cterm=bold ctermfg=234 ctermbg=10 gui=Bold guifg=#1c1c1c guibg=Lime
    highlight Mode_Ts cterm=None ctermfg=10 gui=None guifg=Lime
    highlight Mode_ELSE cterm=bold ctermfg=253 ctermbg=8 gui=Bold guifg=#dadada guibg=#404040
    highlight Mode_ELSEs cterm=None ctermfg=8 gui=None guifg=#404040
    " }}}

    " その他 {{{
    highlight default link Quote String
    highlight qfLineNr ctermfg=22 ctermbg=252 guifg=#205020 guibg=#d0d0d0
    highlight QuickFixLine ctermfg=242 ctermbg=209 guifg=#505050 guibg=#fea085
    highlight default GitStatusLocal ctermbg=2 ctermfg=15 guibg=#50a050 guifg=#f0f0f0
    " }}}

    """ plugin highlights
    for hi_func in meflib#get('plugin_his', [])
        call call(hi_func, [])
    endfor
endfunction

function! <SID>Day_by_Day_StatusLine()
    let [month, day, dow, stl_br, stl_bg, stl_bb] = meflib#color#get_today_rgb()
    let st_modes = split('Mode_Ns Mode_Is Mode_Vs Mode_Rs Mode_Ts Mode_ELSEs', ' ')

    let birthday = meflib#get('birthday', [0,0])
    if (month == birthday[0]) && (day == birthday[1])
        "" Birthday
        highlight StatusLine cterm=Bold ctermfg=241 ctermbg=220 gui=Bold guifg=Grey39 guibg=Gold
        highlight WildMenu cterm=Bold ctermfg=220 ctermbg=241 gui=Bold guifg=Gold guibg=Grey39
        for st_mode in st_modes
            execute printf('highlight %s ctermbg=220 guibg=Gold', st_mode)
        endfor
    else
        let cbg = meflib#color#get_colorid(stl_br, stl_bg, stl_bb, 0)
        let gbg = meflib#color#get_colorid(stl_br, stl_bg, stl_bb, 1)
        if meflib#color#isdark(stl_br/5.0, stl_bg/5.0, stl_bb/5.0)
            let cfg = 255
            let gfg = '#eeeeee'
        else    " light background
            let cfg = 234
            let gfg = '#1c1c1c'
        endif
        " echo 'color:'..stl_br..'='..stl_bg..'='..stl_bb..'='..cfg..'='..cbg..'='..gfg..'='..gbg
        execute printf('highlight StatusLine cterm=Bold ctermfg=%s ctermbg=%s gui=Bold guifg=%s guibg=%s', cfg, cbg, gfg, gbg)
        execute printf('highlight WildMenu cterm=Bold ctermfg=%s ctermbg=%s gui=Bold guifg=%s guibg=%s', cbg, cfg, gbg, gfg)
        for st_mode in st_modes
            execute printf('highlight %s ctermbg=%s guibg=%s', st_mode, cbg, gbg)
        endfor
    endif
    if !has('nvim')
        highlight! link StatusLineTerm StatusLine
    endif
endfunction

augroup colorLocal
    autocmd!
    autocmd ColorScheme * call <SID>my_color_set()

    "全角スペース表示
    autocmd BufEnter * match ZenkakuSpace /　/
    " " と' に文字と違う色を付ける
    autocmd FileType python ++once highlight link pythonQuotes Quote
    autocmd FileType sh ++once highlight link shQuote Quote
    autocmd FileType zsh ++once highlight link zshStringDelimiter Quote
augroup END

try
    execute 'colorscheme '..meflib#get('colorscheme', 'evening')
catch
    colorsche evening
endtry
