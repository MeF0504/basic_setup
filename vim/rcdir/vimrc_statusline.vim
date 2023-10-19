" vim script encoding setting
scriptencoding utf-8
"" vim status line setting

" 常にステータスラインを表示
set laststatus=2
" コマンドラインの画面上の行数
set cmdheight=2

" Anywhere SID. {{{
function! s:SID_PREFIX() " tentative
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
if empty(expand('<SID>'))
    let s:sid = s:SID_PREFIX()
else
    let s:sid = expand('<SID>')
endif
" }}}

let s:per_line = 5
" file format 設定 {{{
function! <SID>get_fileformat(short) abort
    let ff = &fileformat
    if !(line('.')%s:per_line==1)
        if !a:short && meflib#get('plug_opt', 'nerdfont', 0)
            let fa = {'unix': 0xf17c, 'mac': 0xf179, 'dos': 0xf17a}
            if has_key(fa, ff)
                return printf('%s ', nr2char(fa[ff]))
            endif
        endif
        return ''
    endif

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
" }}}

" file type 設定 {{{
function! s:get_filetype() abort
    if line('.')%s:per_line==1
        return printf(' %s ', &filetype)
    else
        if empty(&filetype)
            return ''
        elseif meflib#get('plug_opt', 'nerdfont', 0)
            try
                return printf('%s ', nerdfont#find())
            endtry
        endif
        return ''
    endif
endfunction
" }}}

" mode変換用string {{{
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
    if meflib#get('plug_opt', 'nerdfont', 0)
        let st_mode_split = mode_sep..'%#StatusLine#'
    else
        let st_mode_split = ' %#StatusLine# '
    endif
    return mode_col..st_mode..st_mode_split
endfunction
" }}}

" file name を適当な長さに調整 {{{
function! s:get_rel_filename(status) abort
    let width = winwidth(0)-7-(2+2+len(line('.')..line('$')..col('.')))-5
    " mode, line&col, line percentage
    if meflib#get('plug_opt', 'nerdfont', 0)
        let width = width-2-2
        " ft, ff
    endif
    return "%."..width.."(%f "..a:status.."%)"
endfunction
" }}}

" quick fix title を切り詰めて表示 {{{
function! s:qf_title() abort
    let title = get(w:, 'quickfix_title', '')
    if len(title) >= winwidth(0) -17 -5
        " %t, %l/%L
        let title = title[-(winwidth(0)-22):]
    endif
    return title
endfunction
" }}}

" 修正フラグ 読込専用 ヘルプ preview_window
let s:st_status = "%#StatusLine_ST#%M%R%H%W%#StatusLine#"
" ファイル名&file status (短縮表示なら)
if has('patch-8.2.2854') || has('nvim-0.5.0')
    let s:st_filename1 = "%{%"..s:sid.."get_rel_filename('"..s:st_status.."')%}"
else
    " 古いとサポートしていないっぽい
    let s:st_filename1 = "%f ". s:st_status." "
endif
" winwidthが60より短い場合はファイル名のみ
let s:st_filename2 = "%t ".s:st_status." "
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
" 'qf': statusline for quickfix window
" other(num): statusline for short window. num=max width for this statusline
call meflib#set('statusline', {
            \ '_':   s:st_mode.s:st_filename1.s:st_right.s:st_ft.s:st_ff1.s:st_turn.s:st_ln1,
            \ 'qf': '%t%{'..s:sid..'qf_title()}'..s:st_right..s:st_ln2,
            \ 'off': s:st_off,
            \ '60':  s:st_mode.s:st_filename2.s:st_right.s:st_ft.s:st_ff2.s:st_turn.s:st_ln2,
            \ })

let s:def_statusline = meflib#get('def_statusline', '')
function! <SID>Set_statusline(winid)
    let st_config = meflib#get('statusline', {'_':s:def_statusline})
    if (type(st_config) != type({})) || !has_key(st_config, '_')
        let st_config = {'_':s:def_statusline}
    endif

    " statusline_winid って何時からあった？
    " g: なのにstatusline内でしか参照できないっぽい
    " 対応していないときのために引数のwinidは残しておく
    let winid = g:statusline_winid
    let cur_win = win_getid()==winid
    if !cur_win && has_key(st_config, 'off')
        let st_str = st_config['off']
    elseif (win_gettype(winid) == 'quickfix') && has_key(st_config, 'qf')
        let st_str = st_config['qf']
    else
        let st_str = st_config['_']
        for len in sort(keys(st_config))
            if len=='_' || len=='off' || len=='qf'
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
let &statusline = printf('%%!%sSet_statusline(%d)', s:sid, win_getid())

