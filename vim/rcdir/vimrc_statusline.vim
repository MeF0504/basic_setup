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

call llib#set_local_var('st_fileformat', {"":"", "unix":"unix,LF", "mac":"mac,CR", "dos":"dos,CRLF"})
call llib#set_local_var('st_mode',
            \ {'n':'NORMAL',
            \ 'v':'VISUAL', "\<C-V>":'VISUAL-B', 'V':'VISUAL-L',
            \ 'i':'INSERT',
            \ 'R':'REPLACE',
            \ 't':'TERMINAL',
            \ 'c':'COMMAND',
            \})
" mode
" ファイル名 修正フラグ 読込専用 ヘルプ preview_window
" 切り詰め位置 右端に表示
" filetype
" file format
" 今の行/全体の行-今の列 [%表示]
""" the variable to administer statusline
call llib#set_local_var('statusline', [
            \ " %f%m%{&readonly?'[RO]':''}%h%w ",
            \ "%<%=",
            \ "%#StatusLine_FT# %{&filetype} ",
            \ "%#StatusLine_FF# %{llib#get_local_var('st_fileformat', '')[&fileformat]}:%{&fileencoding} ",
            \ "%#StatusLine_LN# %l/%L-%v %#StatusLine#[%P]",
            \ ])

" パスを除くファイル名 修正フラグ 読込専用 ヘルプ preview_window
call llib#set_local_var('statusline_off', ["%t%m%{&readonly?'[RO]':''}%h%w"])
""" control statusline showing
call llib#set_local_var('st_width_level', [30, 50])
call llib#set_local_var('st_showmode', 1)
function! Set_statusline(cur_win, ...)
    if a:0 == 0
        let l:st_list1 = llib#get_local_var('statusline', ["%f%m%{&readonly?'[RO]':''}%h%w"])
    else
        let l:st_list1 = a:1
    endif

    let st_width_level = llib#get_local_var('st_width_level', [30,50])
    if winwidth(".") < st_width_level[0]
        let l:st_list2 = [l:st_list1[0]]
    elseif winwidth(".") < st_width_level[1]
        if len(st_list1) >= 3
            let l:st_list2 = [l:st_list1[0], l:st_list1[1], l:st_list1[-1]]
        else
            let l:st_list2 = [l:st_list1[0]]
        endif
    else
        let l:st_list2 = l:st_list1
    endif

    let l:st_str = ""
    for l:st in l:st_list2
        let l:st_str .= l:st
    endfor

    if (llib#get_local_var('st_showmode', 1) != 0) && (a:cur_win != 0)
        let st_modes = llib#get_local_var('st_mode', {})
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
        let l:st_str = st_mode . l:st_str
    endif

    return l:st_str
endfunction
set statusline=%!Set_statusline(1)

" on/off 設定
autocmd slLocal WinEnter * if &buftype != 'quickfix' | set statusline=%!Set_statusline(1) | endif
autocmd slLocal WinLeave * if &buftype != 'quickfix' | setlocal statusline=%!Set_statusline(0,llib#get_local_var('statusline_off',[])) | endif

" 長過ぎたらstatusline の最初をファイル名のみにする
autocmd slLocal WinEnter * 
            \ if len(expand('%'))*0.9 > winwidth(0) |
            \ call llib#set_local_var('statusline', [" %t%m%{&readonly?'[RO]':''}%h%w "], [0]) |
            \ else | 
            \ call llib#set_local_var('statusline', [" %f%m%{&readonly?'[RO]':''}%h%w "], [0]) |
            \ endif

