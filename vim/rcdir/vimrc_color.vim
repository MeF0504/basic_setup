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
    highlight String ctermfg=222 ctermbg=None
    highlight Comment ctermfg=31
    highlight LineNr ctermfg=243
    highlight Title ctermfg=197
    highlight SpecialKey cterm=bold ctermfg=255 ctermbg=236
    if has('nvim')
        highlight link Whitespace SpecialKey
    endif
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
    highlight TabLine cterm=None ctermfg=15 ctermbg=16
    highlight TabLineSel cterm=Bold,underline ctermfg=15 ctermbg=243
    highlight TabLineFill cterm=Bold ctermfg=45 ctermbg=16

    "全角スペース表示
    highlight ZenkakuSpace cterm=None ctermfg=None ctermbg=241

    "statusline color setting
    highlight StatusLine cterm=bold ctermfg=234 ctermbg=75
    highlight StatusLineNC cterm=None ctermfg=244 ctermbg=235
    if !has('nvim')
        highlight StatusLineTerm cterm=bold ctermfg=233 ctermbg=46
        highlight StatusLineTermNC cterm=None ctermfg=233 ctermbg=249
    endif

    if exists('*strftime')
        let month = str2nr(strftime("%b"))
        let day = str2nr(strftime("%d"))
        let dow = str2nr(strftime("%w"))
        if ((exists("g:l_bd_month") && (month == g:l_bd_month))
            \&& (exists("g:l_bd_day") && (day == g:l_bd_day)) )
            "" Birthday
            highlight StatusLine cterm=None ctermfg=185 ctermbg=136
            highlight WildMenu cterm=Bold ctermfg=136 ctermbg=185
        else
            let s:stl_br = (dow==6 ? 0 : dow) " 土日は0
            let s:stl_bg = (month-1)%6
            let s:stl_bb =  abs((day+5)%10-5)    " 0 1 2 3 4 5 4 3 2 1 0 ...
            let bg = <SID>get_colorid(s:stl_br, s:stl_bg, s:stl_bb)
            if s:isdark(s:stl_br, s:stl_bg, s:stl_bb) == 1
                let fg = has('gui_running') ? '#eeeeee' : 255
            else    " light background
                let fg = has('gui_running') ? '#1c1c1c' : 234
            endif
            " echo 'color:' . s:stl_br . '=' . s:stl_bg . '=' . s:stl_bb . '=' . bg . '=' . fg
            execute 'highlight StatusLine cterm=Bold ctermfg='.fg.' ctermbg='.bg
            execute 'highlight WildMenu cterm=Bold ctermfg='.bg.' ctermbg='.fg
            if !has('nvim')
                highlight! link StatusLineTerm StatusLine
            endif
        endif
    endif
    "default ... highlight StatusLine term=bold,reverse cterm=bold ctermfg=247 ctermbg=235

endfunction

function! ShowBG()
    let echo_str  = 'red:'.s:stl_br
    let echo_str .= ' green:'.s:stl_bg
    let echo_str .= ' blue:'.s:stl_bb
    let echo_str .= ' => bg:'.<SID>get_colorid(s:stl_br, s:stl_bg, s:stl_bb)
    echo echo_str
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

