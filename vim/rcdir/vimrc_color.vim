"vim script encording setting
scriptencoding utf-8
"" vim color setting

function! <SID>get_colorid(r, g, b)
    if has('gui_running')
        let gui_r = a:r==0 ? 0 : 55+40*a:r
        let gui_g = a:g==0 ? 0 : 55+40*a:g
        let gui_b = a:b==0 ? 0 : 55+40*a:b
        return '#' . printf('%02x', gui_r) . printf('%02x', gui_g) . printf('%02x', gui_b)
    else
        return (36*a:r)+(6*a:g)+a:b + 16
    endif
endfunction

let s:w_r = 1.0 " <- 2.0
let s:w_g = 2.0
let s:w_b = 1.0
let s:thsd = 2.0
function! s:isdark(r, g, b)
    let cond = (a:r*s:w_r+a:g*s:w_g+a:b*s:w_b)/(s:w_r+s:w_g+s:w_b) < s:thsd
    return cond
endfunction

function! <SID>my_color_set_inkpot()
    highlight Identifier ctermfg=110
    highlight Number ctermfg=9
    highlight Type ctermfg=149
    highlight String ctermfg=222 ctermbg=None
    highlight Comment ctermfg=66 gui=italic
    highlight LineNr ctermfg=243
    highlight Title ctermfg=197
    highlight PreProc ctermfg=35    " for gui environment
    highlight SpecialKey cterm=bold ctermfg=255 ctermbg=236
    if has('nvim')
        highlight link Whitespace SpecialKey
    endif
    highlight Normal ctermfg=255
    highlight PmenuThumb ctermbg=55
    highlight MatchParen ctermfg=14 ctermbg=18 cterm=Bold
endfunction

function! s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

function! <SID>my_color_set()
    let local_scheme_func = '<SNR>'.s:SID().'_my_color_set_'.g:colors_name
    if exists('*'.local_scheme_func)
        execute "call ".local_scheme_func.'()'
    else
        " echo "color scheme: " . g:colors_name
    endif

    " general settings
    " corsor line
    highlight CursorLine cterm=underline ctermfg=None ctermbg=None
    highlight CursorLineNr term=Bold cterm=underline ctermfg=17 ctermbg=15

    " tab line
    highlight TabLine cterm=None ctermfg=15 ctermbg=16
    highlight TabLineSel cterm=Bold,underline ctermfg=15 ctermbg=243
    highlight TabLineFill cterm=Bold ctermfg=45 ctermbg=16
    highlight TabLineDir cterm=Bold ctermfg=24 ctermbg=250

    "全角スペース表示
    highlight ZenkakuSpace cterm=None ctermfg=None ctermbg=241

    "statusline color setting
    highlight StatusLine cterm=bold ctermfg=234 ctermbg=75
    highlight StatusLineNC cterm=None ctermfg=244 ctermbg=235
    if !has('nvim')
        highlight StatusLineTerm cterm=bold ctermfg=233 ctermbg=46
        highlight StatusLineTermNC cterm=None ctermfg=233 ctermbg=249
    endif
    highlight StatusLineFT cterm=bold ctermfg=253 ctermbg=17
    highlight StatusLineFF cterm=bold ctermfg=253 ctermbg=88
    highlight StatusLineLN cterm=bold ctermfg=253 ctermbg=29
    highlight StatusLineCFI cterm=bold ctermfg=233 ctermbg=11
    highlight StatusLineN cterm=bold ctermfg=253 ctermbg=0
    highlight StatusLineI cterm=bold ctermfg=253 ctermbg=9
    highlight StatusLineV cterm=bold ctermfg=253 ctermbg=13
    highlight StatusLineR cterm=bold ctermfg=234 ctermbg=3
    highlight StatusLineT cterm=bold ctermfg=234 ctermbg=10

    """ plugin highlights
    " NERDTree
    highlight NERDTreeBookmarksLeader ctermfg=32
    highlight NERDTreeBookmark ctermfg=107
    
    " hitspop
    highlight hitspopNormal ctermfg=224 ctermbg=238
    highlight hitspopErrorMsg ctermfg=9 ctermbg=238

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
            let s:stl_br = (dow==6 ? 0 : dow)   " 土日は0
            let s:stl_bg = (month-1)%6
            let s:stl_bb = abs((day+4)%10-5)    " 0 1 2 3 4 5 4 3 2 1 0 ...
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
    let echo_str .= '   is_dark:'
    let echo_str .= ' ('.s:stl_br.'*'.printf('%.1f', s:w_r)
    let echo_str .= '+'.s:stl_bg.'*'.printf('%.1f', s:w_g)
    let echo_str .= '+'.s:stl_bb.'*'.printf('%.1f', s:w_b).')'
    let echo_str .= printf('%s%.1f%s%.1f%s%.1f%s', '/(', s:w_r, '+', s:w_g, '+', s:w_b, ')')
    let echo_str .= ' = '.printf('%.1f', (s:stl_br*s:w_r+s:stl_bg*s:w_g+s:stl_bb*s:w_b)/(s:w_r+s:w_g+s:w_b))
    let echo_str .= ' < '.printf('%.2f', s:thsd)
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
augroup END

try
    colorscheme inkpot
catch
    colorscheme desert
endtry

