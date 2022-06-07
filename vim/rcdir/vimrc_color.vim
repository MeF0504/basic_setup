" vim script encoding setting
scriptencoding utf-8
"" vim color settings

" Anywhere SID.
function! s:SID_PREFIX() " tentative
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
if empty(expand('<SID>'))
    let s:sid = s:SID_PREFIX()
else
    let s:sid = expand('<SID>')
endif

function! <SID>get_colorid(r, g, b, gui)
    if a:gui
        let gui_r = a:r==0 ? 0 : 55+40*a:r
        let gui_g = a:g==0 ? 0 : 55+40*a:g
        let gui_b = a:b==0 ? 0 : 55+40*a:b
        return '#' . printf('%02x', gui_r) . printf('%02x', gui_g) . printf('%02x', gui_b)
    else
        return (36*a:r)+(6*a:g)+a:b + 16
    endif
endfunction

" refer RGB -> YUV conversion equation
let s:w_r = 0.299 " <- 1.0
let s:w_g = 0.587 " <- 2.0
let s:w_b = 0.114 " <- 1.0
let s:thsd = 2.1
function! s:isdark(r, g, b)
    let cond = (a:r*s:w_r+a:g*s:w_g+a:b*s:w_b)/(s:w_r+s:w_g+s:w_b) < s:thsd
    return cond
endfunction

function! Chk_isdark() abort
    if has('gui_running')
        echo 'gui is not supported'
        return
    endif

    echo "\n"
    for g in range(6)
        for r in range(6)
            for b in range(6)
                let i = 36*r+6*g+b+16
                if s:isdark(r, g, b)
                    let fg = 255
                else
                    let fg = 234
                endif
                " echo 'highlight tmpHl'..i..' ctermfg='..fg..' ctermbg='..i
                execute 'highlight tmpHl'..i..' ctermfg='..fg..' ctermbg='..i
                execute 'echohl tmpHl'..i
                echon printf('%02x', i)
            endfor
            echohl None
            echon ' '
        endfor
        echo ''
    endfor
    echohl None
    echo ''
endfunction

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

function! <SID>my_color_set_shiki()
    highlight Directory ctermfg=34 guifg=#00af00
endfunction

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

function! <SID>my_color_set_PaperColor()
    highlight Search ctermbg=36 guibg=#00af87
    highlight SpecialKey cterm=Underline ctermfg=245 ctermbg=233 gui=Underline guifg=#8a8a8a guibg=#121212
endfunction

function! <SID>my_color_set_evening()
    highlight Normal ctermbg=233 guibg=#121212
        highlight DiffAdd ctermfg=15 ctermbg=4 guifg=White guibg=DarkBlue
        highlight DiffChange ctermfg=15 ctermbg=5 guifg=White guibg=DarkMagenta
        highlight DiffDelete ctermfg=15 ctermbg=6 guifg=White guibg=DarkCyan
        highlight DiffText ctermfg=15 ctermbg=9 guifg=White guibg=Red
endfunction

function! <SID>my_color_set_night_owl()
    highlight Pmenu ctermfg=7
    highlight Quote ctermfg=37 guifg=#00d7d7
    highlight Comment ctermfg=243 ctermbg=233 guifg=#637777 guibg=#011627 cterm=NONE
    highlight shComment ctermfg=243 ctermbg=233 guifg=#637777 guibg=#011627 cterm=NONE
    highlight SpecialKey ctermbg=235 guibg=#202020
    highlight Number ctermfg=162 guifg=#c02a8f
    highlight Todo ctermfg=17 ctermbg=228 cterm=BOLD guifg=#101060 guibg=#f8fa6a gui=BOLD
    highlight LineNr ctermfg=240 guifg=#535353

    highlight HiTagImports ctermfg=227 guifg=#f0e860
endfunction

function! <SID>my_color_set_inkpotter()
    highlight CursorWord1 ctermbg=235 cterm=None guibg=#262626 gui=NONE
    highlight Quote ctermfg=183 ctermbg=None guifg=#d7afff guibg=NONE

    highlight HiTagImports ctermfg=225 guifg=#f0b7f0
endfunction

function! <SID>my_color_set_modus_operandi() abort
    " ctermがない？
    highlight DiffDelete gui=Bold guifg=#939393 guibg=#e0ffff
    highlight SpecialKey gui=None guifg=#101010 guibg=#cacaca
    highlight ErrorMsg gui=Bold guifg=#000000 guibg=#a80000
    highlight WarningMsg gui=Bold guifg=#000000 guibg=#909000
endfunction

function! <SID>my_color_set()
    """ general settings
    " link {{{
    highlight link VimFunction Identifier
    highlight link vimIsCommand SpecialChar
    highlight link keepend Special
    if has('nvim')
        highlight link Whitespace SpecialKey
    endif
    " }}}

    " corsor line {{{
    if g:colors_name !~ 'pjsekai_*'
        highlight CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=15 gui=Underline guifg=#00005f guibg=White
    endif
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

    highlight StatusLineNC cterm=underline ctermfg=244 ctermbg=232 gui=Underline guifg=#808080 guibg=#080808
    if !has('nvim')
        highlight StatusLineTermNC cterm=None ctermfg=233 ctermbg=249 gui=NONE guifg=#121212 guibg=#b2b2b2
    endif

    if &background == 'dark'
        highlight StatusLine_ST cterm=None ctermfg=10 ctermbg=236 gui=NONE guifg=#00FF00 guibg=#333333
        highlight StatusLine_FT cterm=bold ctermfg=253 ctermbg=17 gui=Bold guifg=#dadada guibg=#00005f
        highlight StatusLine_FF cterm=bold ctermfg=253 ctermbg=88 gui=Bold guifg=#dadada guibg=#870000
        highlight StatusLine_LN cterm=bold ctermfg=253 ctermbg=29 gui=Bold guifg=#dadada guibg=#00875f
        highlight StatusLine_CHK cterm=bold ctermfg=233 ctermbg=190 gui=Bold guifg=#121212 guibg=#d7ff00
    else
        highlight StatusLine_ST cterm=None ctermfg=29 ctermbg=253 gui=NONE guifg=#008050 guibg=#dddddd
        highlight StatusLine_FT cterm=bold ctermfg=236 ctermbg=68 gui=Bold guifg=#303030 guibg=#73a9ff
        highlight StatusLine_FF cterm=bold ctermfg=236 ctermbg=210 gui=Bold guifg=#303030 guibg=#ffa0a0
        highlight StatusLine_LN cterm=bold ctermfg=236 ctermbg=119 gui=Bold guifg=#303030 guibg=#70ff80
        highlight StatusLine_CHK cterm=bold ctermfg=233 ctermbg=190 gui=Bold guifg=#121212 guibg=#d7ff00
    endif
    highlight Mode_N cterm=bold ctermfg=253 ctermbg=0 gui=Bold guifg=#dadada guibg=Black
    highlight Mode_I cterm=bold ctermfg=253 ctermbg=9 gui=Bold guifg=#dadada guibg=Red
    highlight Mode_V cterm=bold ctermfg=253 ctermbg=13 gui=Bold guifg=#dadada guibg=Fuchsia
    highlight Mode_R cterm=bold ctermfg=234 ctermbg=3 gui=Bold guifg=#1c1c1c guibg=Olive
    highlight Mode_T cterm=bold ctermfg=234 ctermbg=10 gui=Bold guifg=#1c1c1c guibg=Lime
    highlight Mode_ELSE cterm=bold ctermfg=253 ctermbg=8 gui=Bold guifg=#dadada guibg=#404040
    " }}}

    " その他 {{{
    " highlight ToCkeys ctermfg=10 guifg=Lime
    if (&background == 'light') && exists(':SeiyaDisable')
        silent SeiyaDisable
    endif
    highlight default link Quote String
    highlight qfLineNr ctermfg=22 ctermbg=252 guifg=#205020 guibg=#d0d0d0
    " }}}

    """ plugin highlights
    " hitspop {{{
    highlight hitspopNormal ctermfg=224 ctermbg=238 guifg=#ffd7d7 guibg=#444444
    highlight hitspopErrorMsg ctermfg=9 ctermbg=238 guifg=Red guibg=#444444
    " }}}

    " ParenMatch {{{
    highlight link ParenMatch MatchParen
    " }}}

    " Untitled {{{
    if g:colors_name =~ 'pjsekai_*'
        if exists(':SeiyaDisable')
            SeiyaDisable
        endif
    endif
    " }}}

    " CursorWord {{{
    highlight CursorWord1 ctermfg=None ctermbg=None cterm=None guifg=NONE guifg=NONE gui=NONE
    highlight CursorWord0 ctermfg=None ctermbg=None cterm=underline guifg=NONE guifg=NONE gui=Underline
    " }}}

    " current-func-info {{{
    highlight CFIPopup ctermbg=11 ctermfg=233 cterm=bold guibg=Yellow guifg=#121212 gui=Bold
    " }}}

    " highlightag {{{
    highlight HiTagClasses ctermfg=171 guifg=#d75fff
    highlight HiTagMembers ctermfg=69 guifg=#5f87ff
    " }}}

    " indent-guides {{{
    if &background == 'dark'
        highlight IndentGuidesOdd ctermfg=17 ctermbg=17 guifg=#003851 guibg=#003851
        highlight IndentGuidesEven ctermfg=54 ctermbg=54 guifg=#3f0057 guibg=#3f0057
    else
        highlight IndentGuidesOdd ctermfg=147 ctermbg=147 guifg=#a0f8f8 guibg=#a0f8f8
        highlight IndentGuidesEven ctermfg=219 ctermbg=219 guifg=#f8a0f8 guibg=#f8a0f8
    endif
    " }}}

    " anzu {{{
    highlight link AnzuPopup hitspopNormal
    " }}}

    " Gitewer {{{
    if &background == 'light'
        highlight GitewerDate ctermfg=135 guifg=#af8700
        highlight GitewerCommit ctermfg=243 guifg=#767676
    endif
    " }}}

    " Fern {{{
    highlight FernMarkedText ctermfg=196 guifg=#ff0000
    highlight FernRootSymbol ctermfg=11 guifg=#ffff00
    highlight FernBranchSymbol ctermfg=10 guifg=#00ff00
    highlight FernBranchText ctermfg=2 guifg=#008000
    highlight FernLeafSymbol ctermfg=43 guifg=#00af5f
    if &background == 'dark'
        highlight FernRootText ctermfg=220 guifg=#d0d000
    else
        highlight FernRootText ctermfg=100 guifg=#9a9a00
    endif
    " }}}

    " colorscheme specified setings
    let colname = substitute(g:colors_name, "-", "_", "g")
    let local_scheme_func = s:sid..'my_color_set_'..colname
    if exists('*'.local_scheme_func)
        execute "call ".local_scheme_func.'()'
    else
        " echo "color scheme: " . g:colors_name
    endif
endfunction

function! <SID>Day_by_Day_StatusLine()
    let month = str2nr(strftime("%b"))
    let day = str2nr(strftime("%d"))
    let dow = str2nr(strftime("%w"))
    let s:stl_br = (dow==6 ? 0 : dow)       " 土日は0
    let s:stl_bg = (month+(day-1)/10-1)%6   " 月+(日-1)の十の位で計算
    let s:stl_bb = abs((day+5-1)%10-5)      " 0 1 2 3 4 5 4 3 2 1 0 ...

    let barthday = meflib#get_local_var('barthday', [0,0])
    if (month == barthday[0]) && (day == barthday[1])
        "" Birthday
        highlight StatusLine cterm=None ctermfg=7 ctermbg=136 gui=NONE guifg=Silver guibg=Gold
        highlight WildMenu cterm=Bold ctermfg=136 ctermbg=7 gui=NONE guifg=Gold guibg=Silver
    else
        let cbg = <SID>get_colorid(s:stl_br, s:stl_bg, s:stl_bb, 0)
        let gbg = <SID>get_colorid(s:stl_br, s:stl_bg, s:stl_bb, 1)
        if s:isdark(s:stl_br, s:stl_bg, s:stl_bb) == 1
            let cfg = 255
            let gfg = '#eeeeee'
        else    " light background
            let cfg = 234
            let gfg = '#1c1c1c'
        endif
        " echo 'color:'..s:stl_br..'='..s:stl_bg..'='..s:stl_bb..'='..cfg..'='..cbg..'='..gfg..'='..gbg
        execute printf('highlight StatusLine cterm=Bold ctermfg=%s ctermbg=%s gui=Bold guifg=%s guibg=%s', cfg, cbg, gfg, gbg)
        execute printf('highlight WildMenu cterm=Bold ctermfg=%s ctermbg=%s gui=Bold guifg=%s guibg=%s', cbg, cfg, gbg, gfg)
        if !has('nvim')
            highlight! link StatusLineTerm StatusLine
        endif
    endif
endfunction

function! ShowStatusLineBG()
    let is_gui = has('gui_running') || (has('termguicolors') && &termguicolors)
    let echo_str  = 'red:'.s:stl_br
    let echo_str .= ' green:'.s:stl_bg
    let echo_str .= ' blue:'.s:stl_bb
    let echo_str .= ' => bg:'.<SID>get_colorid(s:stl_br, s:stl_bg, s:stl_bb, is_gui)
    let echo_str .= '   is_dark:'
    let echo_str .= ' ('.s:stl_br.'*'.printf('%.1f', s:w_r)
    let echo_str .= '+'.s:stl_bg.'*'.printf('%.1f', s:w_g)
    let echo_str .= '+'.s:stl_bb.'*'.printf('%.1f', s:w_b).')'
    let echo_str .= printf('%s%.1f%s%.1f%s%.1f%s', '/(', s:w_r, '+', s:w_g, '+', s:w_b, ')')
    let echo_str .= ' = '.printf('%.3f', (s:stl_br*s:w_r+s:stl_bg*s:w_g+s:stl_bb*s:w_b)/(s:w_r+s:w_g+s:w_b))
    let echo_str .= ' < '.printf('%.3f', s:thsd)
    echo echo_str
endfunction

augroup colorLocal
    autocmd!
    autocmd ColorScheme * call <SID>my_color_set()

    " corsor line
    " autocmd InsertLeave * highlight CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=15
    " autocmd InsertEnter * highlight CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=97

    "全角スペース表示
    autocmd BufEnter * match ZenkakuSpace /　/
    " :h :syn-matchgroup
    " " と' にも色を付ける (test)
    " autocmd Syntax * syntax region String matchgroup=Quote start=+\("\|'\)+ skip=+\\\("\|'\)+ end=+\("\|'\)+
    " autocmd Syntax * syntax region String oneline matchgroup=Quote start="'" skip="\\'" end="'"
    " autocmd Syntax * syntax region String matchgroup=Quote start="'''" end="'''"
    " う〜ん，やっぱりやめるかなぁ。最初からあるやつだけ...
    autocmd FileType python ++once highlight link pythonQuotes Quote
    autocmd FileType sh ++once highlight link shQuote Quote
    autocmd FileType zsh ++once highlight link zshStringDelimiter Quote
augroup END

try
    execute 'colorscheme '..meflib#get_local_var('colorscheme', 'evening')
catch
    colorsche evening
endtry

