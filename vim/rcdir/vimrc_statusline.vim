" vim script encoding setting
scriptencoding utf-8
"" vim status line setting

" 常にステータスラインを表示
set laststatus=2
" コマンドラインの画面上の行数
set cmdheight=2

" Anywhere SID.
function! s:SID_PREFIX() " tentative
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
if empty(expand('<SID>'))
    let s:sid = s:SID_PREFIX()
else
    let s:sid = expand('<SID>')
endif

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

" mode変換用string
let s:mode_str = '%%mode'
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

" 修正フラグ 読込専用 ヘルプ preview_window
let s:st_status = "%#StatusLine_ST#%M%R%H%W%#StatusLine#"
" ファイル名&file status (最大長 windowの2/3)
if has('patch-8.2.2854') || has('nvim-0.5.0')
    let s:st_filename1 = printf(" %%{%%'%s'.%s.'%s %s %s'%%} ", '%.', 'winwidth(0)*2/3', '(%f', s:st_status, '%)')
else
    " 古いとサポートしていないっぽい
    let s:st_filename1 = " %f". s:st_status." "
endif
" winwidthが60より短い場合はファイル名のみ
let s:st_filename2 = " %t ".s:st_status." "
" 切り詰め位置 右端に表示
let s:st_turn = "%<%="
" filetype
let s:st_ft = "%#StatusLine_FT# %{&filetype} "
" file format
let s:st_ff1 = "%#StatusLine_FF# %{"..s:sid.."get_fileformat(&fileformat)}:%{&fileencoding} "
let s:st_ff2 = "%#StatusLine_FF# %{&fileformat}:%{&fileencoding} "
" 今の行/全体の行-今の列 [%表示]
let s:st_ln1 = "%#StatusLine_LN# %l/%L-%v %#StatusLine#[%P]"
" winwidthが60より短い時は列と%はなし
let s:st_ln2 = "%#StatusLine_LN# %l/%L"

" パスを除くファイル名 修正フラグ 読込専用 ヘルプ preview_window
let s:st_off = "%t %m%{&readonly?'[RO]':''}%h%w"

""" the variable to administer statusline
" '_': basic statusline
" 'off': statusline for off window
" other(num): statusline for short window. num=max width for this statusline
call meflib#set_local_var('statusline', {
            \ '_':   s:mode_str.s:st_filename1.s:st_turn.s:st_ft.s:st_ff1.s:st_ln1,
            \ 'off': s:st_off,
            \ '60':  s:mode_str.s:st_filename2.s:st_turn.s:st_ft.s:st_ff2.s:st_ln2,
            \ })

let s:def_statusline = &statusline
function! <SID>Set_statusline(cur_win)
    let st_config = meflib#get_local_var('statusline', {'_':s:def_statusline})
    if (type(st_config) != type({})) || !has_key(st_config, '_')
        let st_config = {'_':s:def_statusline}
    endif

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

    " replace mode_str to mode information
    if (meflib#get_local_var('st_showmode', 1) != 0) && (match(st_str, s:mode_str)!=-1)
        let st_str = substitute(st_str, s:mode_str, <SID>get_mode(), 'g')
    endif

    return st_str
endfunction
let &statusline = '%!'..s:sid..'Set_statusline(1)'

augroup slLocal
    autocmd!
    " on/off 設定
    autocmd WinEnter * if &buftype != 'quickfix' | let &statusline='%!'..s:sid..'Set_statusline(1)' | endif
    autocmd WinLeave * if &buftype != 'quickfix' | execute 'setlocal statusline=%!'..s:sid..'Set_statusline(0)' | endif
augroup END

