" vim script encoding setting
scriptencoding utf-8
"" vim status line setting

" 常にステータスラインを表示
set laststatus=2
" コマンドラインの画面上の行数
set cmdheight=2
augroup slLocal
    autocmd!
augroup END

function! <SID>get_fileformat(os)
    if a:os == 'unix'
        return 'unix,LF'
    elseif a:os == 'mac'
        return 'mac,CR'
    elseif a:os == 'dos'
        return 'dos,CRLF'
    else
        return ''
    endif
endfunction

function! <SID>get_mode()
    let st_modes =
                \ {'n':'NORMAL',
                \ 'v':'VISUAL', "\<C-V>":'VISUAL-B', 'V':'VISUAL-L',
                \ 'i':'INSERT',
                \ 'R':'REPLACE',
                \ 't':'TERMINAL',
                \ 'c':'COMMAND',
                \ }
    let modec = mode()
    " mode string setting
    let st_mode = has_key(st_modes, modec) ? st_modes[modec] : modec
    " color setting
    let st_mode .= ' %#StatusLine#'
    if modec =~ 'i'
        let st_mode = '%#Mode_I#' . st_mode
    elseif modec =~ 'v' || modec == "\<C-V>"
        let st_mode = '%#Mode_V#' . st_mode
    elseif modec =~ 'r'
        let st_mode = '%#Mode_R#' . st_mode
    elseif modec =~ 't'
        let st_mode = '%#Mode_T#' . st_mode
    elseif modec =~ 'n'
        let st_mode = '%#Mode_N#' . st_mode
    else
        let st_mode = '%#Mode_ELSE#' . st_mode
    endif
    return st_mode
endfunction

let s:st_normal = ""
let s:st_level1 = ""
" ファイル名(最大長50) 修正フラグ 読込専用 ヘルプ preview_window
let s:st_normal .= " %.50f%m%{&readonly?'[RO]':''}%h%w "
" winwidthが60より短い場合はファイル名のみ
let s:st_level1 .= " %t%m%{&readonly?'[RO]':''}%h%w "
" 切り詰め位置 右端に表示
let s:st_normal .= "%<%="
let s:st_level1 .= "%<%="
" filetype
let s:st_normal .= "%#StatusLine_FT# %{&filetype} "
let s:st_level1 .= "%#StatusLine_FT# %{&filetype} "
" file format
let s:st_normal .= "%#StatusLine_FF# %{"..expand('<SID>').."get_fileformat(&fileformat)}:%{&fileencoding} "
let s:st_level1 .= "%#StatusLine_FF# %{"..expand('<SID>').."get_fileformat(&fileformat)}:%{&fileencoding} "
" 今の行/全体の行-今の列 [%表示]
let s:st_normal .= "%#StatusLine_LN# %l/%L-%v %#StatusLine#[%P]"
" winwidthが60より短い時は列と%はなし
let s:st_level1 .= "%#StatusLine_LN# %l/%L"

" パスを除くファイル名 修正フラグ 読込専用 ヘルプ preview_window
let s:st_off = "%t%m%{&readonly?'[RO]':''}%h%w"

""" the variable to administer statusline
" '_': basic statusline
" 'off': statusline for off window
" other(num): statusline for short window. num=max width for this statusline
call llib#set_local_var('statusline', {
            \ '_':   s:st_normal,
            \ 'off': s:st_off,
            \ '60':  s:st_level1,
            \ })

let s:def_statusline = &statusline
function! <SID>Set_statusline(cur_win)
    let st_config = llib#get_local_var('statusline', {'_':s:def_statusline})

    if a:cur_win == 0 && has_key(st_config, 'off')
        let st_str = st_config['off']
    else
        let st_str = st_config['_']
        for len in sort(keys(st_config))
            if len=='_' || len=='off'
                continue
            else
                if winwidth(0) < str2nr(len)
                    let st_str = st_config[len]
                endif
            endif
        endfor
    endif

    if (llib#get_local_var('st_showmode', 1) != 0) && (a:cur_win != 0)
        let st_str = <SID>get_mode()..st_str
    endif

    return st_str
endfunction
let &statusline = '%!'..expand('<SID>')..'Set_statusline(1)'

" on/off 設定
autocmd slLocal WinEnter * if &buftype != 'quickfix' | let &statusline='%!'..expand('<SID>')..'Set_statusline(1)' | endif
autocmd slLocal WinLeave * if &buftype != 'quickfix' | execute 'setlocal statusline=%!'..expand('<SID>')..'Set_statusline(0)' | endif

