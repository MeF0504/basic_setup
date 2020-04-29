"vim script encording setting
scriptencoding utf-8
"" vim color setting

augroup colorLocal
    autocmd!
augroup END

function! <SID>my_color_set()
    if g:colors_name == "inkpot"
        highlight Identifier ctermfg=110
        highlight Number ctermfg=9
        highlight Type ctermfg=149
        highlight String ctermbg=None ctermfg=222
        highlight Comment ctermfg=62
        highlight LineNr ctermfg=239
        "highlight Comment ctermfg=212
        highlight StatusLineTerm cterm=bold ctermfg=233 ctermbg=46
        highlight StatusLineTermNC ctermfg=233 ctermbg=249
        highlight SpecialKey ctermfg=None ctermbg=236
    else
        echo "color scheme: " . g:colors_name
    endif
endfunction

autocmd colorLocal ColorScheme * call <SID>my_color_set()

try
    colorscheme inkpot
catch
    colorscheme desert
endtry

" corsor line
highlight CursorLine cterm=underline ctermfg=None ctermbg=None
highlight CursorLineNr term=Bold ctermfg=17 ctermbg=15
autocmd colorLocal InsertLeave * highlight CursorLineNr term=Bold ctermfg=17 ctermbg=15
autocmd colorLocal InsertEnter * highlight CursorLineNr term=Bold ctermfg=17 ctermbg=97

"全角スペース表示
highlight ZenkakuSpace ctermbg=241
autocmd colorLocal BufEnter * match ZenkakuSpace /　/

"statusline color setting
let s:month = str2nr(strftime("%b"))
let s:day = str2nr(strftime("%d"))
if ((exists("g:l_bd_month") && (s:month == g:l_bd_month))
    \&& (exists("g:l_bd_day") && (s:day == g:l_bd_day)) )
    "" Birthday
    highlight StatusLine ctermfg=185 ctermbg=136
    highlight WildMenu ctermfg=136 ctermbg=185
elseif (s:month == 3) || (s:month == 4 ) || (s:month == 5)
    "" Spring
    highlight StatusLine ctermfg=218 ctermbg=90
    highlight WildMenu ctermfg=90 ctermbg=218
elseif (s:month == 6) || (s:month == 7 ) || (s:month == 8)
    "" Summer
    highlight StatusLine ctermfg=154 ctermbg=27
    highlight WildMenu ctermfg=27 ctermbg=154
elseif (s:month == 9) || (s:month == 10 ) || (s:month == 11)
    "" Fall
    highlight StatusLine ctermfg=184 ctermbg=88
    highlight WildMenu ctermfg=88 ctermbg=184
elseif (s:month == 12) || (s:month == 1 ) || (s:month == 2)
    "" Winter
    highlight StatusLine ctermfg=109 ctermbg=17
    highlight WildMenu ctermfg=17 ctermbg=109
else
    highlight StatusLine ctermfg=247 ctermbg=235
    highlight WildMenu ctermfg=235 ctermbg=247
endif
"default ... highlight StatusLine term=bold,reverse cterm=bold ctermfg=247 ctermbg=235

