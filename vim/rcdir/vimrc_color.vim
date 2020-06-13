"vim script encording setting
scriptencoding utf-8
"" vim color setting

function! <SID>get_colorid(r, g, b)
    if has('gui_running')
        return '#' . printf('%02x', a:r*50) . printf('%02x', a:g*50) . printf('%02x', a:b*50)
    else
        return (36*a:r)+(6*a:g)+a:b + 16
    endif
endfunction
function! s:isdark(r, g, b)
    if a:r < 4
        let cond = (a:g<3 && a:g+a:b < 6)
    else
        let cond = a:g*a:g+a:b*a:b < (7-a:r)*(7-a:r)
    endif
    return cond
endfunction

function! <SID>my_color_set_inkpot()
    highlight Identifier ctermfg=110
    highlight Number ctermfg=9
    highlight Type ctermfg=149
    highlight String ctermbg=None ctermfg=222
    highlight Comment ctermfg=31
    highlight LineNr ctermfg=239
    highlight StatusLineTerm cterm=bold ctermfg=233 ctermbg=46
    highlight StatusLineTermNC ctermfg=233 ctermbg=249
    highlight SpecialKey ctermfg=None ctermbg=236
    highlight Normal ctermfg=255
endfunction

function! <SID>my_color_set()
    if g:colors_name == "inkpot"
        call <SID>my_color_set_inkpot()
    else
        echo "color scheme: " . g:colors_name
    endif

    " general settings
    " corsor line
    highlight CursorLine cterm=underline ctermfg=None ctermbg=None
    highlight CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=15

    " tab line
    highlight TabLine cterm=underline ctermfg=15 ctermbg=243
    highlight TabLineSel cterm=Bold ctermfg=15 ctermbg=16
    highlight TabLineFill cterm=Bold ctermfg=45 ctermbg=16

    "全角スペース表示
    highlight ZenkakuSpace cterm=None ctermfg=None ctermbg=241

    "statusline color setting
    if exists('*strftime')
        let s:month = str2nr(strftime("%b"))
        let s:day = str2nr(strftime("%d"))
        let s:dow = str2nr(strftime("%w"))
        if ((exists("g:l_bd_month") && (s:month == g:l_bd_month))
            \&& (exists("g:l_bd_day") && (s:day == g:l_bd_day)) )
            "" Birthday
            highlight StatusLine cterm=None ctermfg=185 ctermbg=136
            highlight WildMenu cterm=Bold ctermfg=136 ctermbg=185
        else
            let s:stl_br = (s:dow==6 ? 0 : s:dow) " 土日は0
            let s:stl_bg = (s:month-1)%6
            let s:stl_bb = (s:day-1)%6
            let s:bg = <SID>get_colorid(s:stl_br, s:stl_bg, s:stl_bb)
            if s:isdark(s:stl_br, s:stl_bg, s:stl_bb) == 1
                let s:fg = has('gui_running') ? '#eeeeee' : 255
            else    " light background
                let s:fg = has('gui_running') ? '#1c1c1c' : 234
            endif
            " echo 'color:' . s:stl_br . '=' . s:stl_bg . '=' . s:stl_bb . '=' . s:bg . '=' . s:fg
            execute 'highlight StatusLine cterm=Bold ctermfg='.s:fg.' ctermbg='.s:bg
            execute 'highlight WildMenu cterm=Bold ctermfg='.s:bg.' ctermbg='.s:fg
        endif
    endif
    "default ... highlight StatusLine term=bold,reverse cterm=bold ctermfg=247 ctermbg=235

endfunction

augroup colorLocal
    autocmd!
    autocmd ColorScheme * call <SID>my_color_set()

    " corsor line
    autocmd InsertLeave * highlight CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=15
    autocmd InsertEnter * highlight CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=97

    "全角スペース表示
    autocmd BufEnter * match ZenkakuSpace /　/
augroup END

try
    colorscheme inkpot
catch
    colorscheme desert
endtry

