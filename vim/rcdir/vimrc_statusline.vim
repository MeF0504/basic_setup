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

" let s:show_ft_ff = 1
" file format 設定
function! <SID>get_fileformat(short) abort
    if !(line('.')%5==1)
        return ''
    endif

    let ff = &fileformat
    if a:short
        " do nothing
    elseif ff == 'unix'
        let ff = 'unix,LF'
    elseif ff == 'mac'
        let ff = 'mac,CR'
    elseif ff == 'dos'
        let ff = 'dos,CRLF'
    else
        let ff = ''
    endif
    let fe = &fileencoding
    " 何故か最初に2個spaceが必要？
    return printf('  %s:%s ', ff, fe)
endfunction

" file type 設定
function! s:get_filetype() abort
    if meflib#get('load_plugin', 0, 'nerdfont')
        try
            return printf('%s ', nerdfont#find())
        endtry
    endif
    if line('.')%5==1
        return printf(' %s ', &filetype)
    else
        return ''
    endif
endfunction

" mode変換用string
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
    if modec =~ 'i'
        let mode_col = '%#Mode_I#'
        let mode_sep = '%#Mode_Is#'..nr2char(0xe0b0)
    elseif modec =~ 'v' || modec == "\<C-V>"
        let mode_col = '%#Mode_V#'
        let mode_sep = '%#Mode_Vs#'..nr2char(0xe0b0)
    elseif modec =~ 'r'
        let mode_col = '%#Mode_R#'
        let mode_sep = '%#Mode_Rs#'..nr2char(0xe0b0)
    elseif modec =~ 't'
        let mode_col = '%#Mode_T#'
        let mode_sep = '%#Mode_Ts#'..nr2char(0xe0c4)..' '
    elseif modec =~ 'n'
        let mode_col = '%#Mode_N#'
        let mode_sep = '%#Mode_Ns#'..nr2char(0xe0b0)
    else
        let mode_col = '%#Mode_ELSE#'
        let mode_sep = '%#Mode_ELSEs#'..nr2char(0xe0b0)
    endif
    " separator
    if meflib#get('load_plugin', 0, 'nerdfont')
        let st_mode_split = mode_sep..'%#StatusLine#'
    else
        let st_mode_split = ' %#StatusLine# '
    endif
    return mode_col..st_mode..st_mode_split
endfunction

function! <SID>get_rel_filename(status) abort
    let width = winwidth(0)*2/3
    return "%."..width.."(%f "..a:status.."%)"
endfunction

" 修正フラグ 読込専用 ヘルプ preview_window
let s:st_status = "%#StatusLine_ST#%M%R%H%W%#StatusLine#"
" ファイル名&file status (最大長 windowの2/3)
if has('patch-8.2.2854') || has('nvim-0.5.0')
    let s:st_filename1 = "%{%"..s:sid.."get_rel_filename('"..s:st_status.."')%}"
else
    " 古いとサポートしていないっぽい
    let s:st_filename1 = "%f ". s:st_status." "
endif
" winwidthが60より短い場合はファイル名のみ
let s:st_filename2 = " %t ".s:st_status." "
" 切り詰め位置
let s:st_turn = "%<"
" 右端に表示
let s:st_right = "%="
" filetype
let s:st_ft = "%#StatusLine_FT#%{"..s:sid.."get_filetype()}"
" file format
let s:st_ff1 = "%#StatusLine_FF#%{"..s:sid.."get_fileformat(0)}"
let s:st_ff2 = "%#StatusLine_FF#%{"..s:sid.."get_fileformat(1)}"
" 今の行/全体の行-今の列 [%表示]
let s:st_ln1 = "%#StatusLine_LN# %l/%L-%v %#StatusLine#[%p%%]"
" winwidthが60より短い時は列と%はなし
let s:st_ln2 = "%#StatusLine_LN# %l/%L"
" 可能ならstatus lineにmodeを表示
if has('patch-8.2.2854') || has('nvim-0.5.0')
    let s:st_mode = "%{%".s:sid."get_mode()%}"
    set noshowmode
else
    let s:st_mode = ' '
endif

" パスを除くファイル名 修正フラグ 読込専用 ヘルプ preview_window
let s:st_off = "%#StatusLine_OFF#<%t>%#StatusLineNC# %m%{&readonly?'[RO]':''}%h%w"

""" the variable to administer statusline
" '_': basic statusline
" 'off': statusline for off window
" other(num): statusline for short window. num=max width for this statusline
call meflib#set('statusline', {
            \ '_':   s:st_mode.s:st_filename1.s:st_right.s:st_ft.s:st_ff1.s:st_turn.s:st_ln1,
            \ 'off': s:st_off,
            \ '60':  s:st_mode.s:st_filename2.s:st_right.s:st_ft.s:st_ff2.s:st_turn.s:st_ln2,
            \ })

let s:def_statusline = &statusline
function! <SID>Set_statusline(cur_win)
    let st_config = meflib#get('statusline', {'_':s:def_statusline})
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

    return st_str
endfunction
let &statusline = '%!'..s:sid..'Set_statusline(1)'

augroup slLocal
    autocmd!
    " on/off 設定
    autocmd WinEnter * if &buftype != 'quickfix' | let &statusline='%!'..s:sid..'Set_statusline(1)' | endif
    autocmd WinLeave * if &buftype != 'quickfix' | execute 'setlocal statusline=%!'..s:sid..'Set_statusline(0)' | endif
    " autocmd CursorMoved * let s:show_ft_ff = 0
    " autocmd CursorMovedI * let s:show_ft_ff = 0
    " autocmd CursorHold * let s:show_ft_ff = 1
    " autocmd CursorHoldI * let s:show_ft_ff = 1
augroup END

