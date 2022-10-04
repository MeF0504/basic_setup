" vim script encoding setting
scriptencoding utf-8
"" vim tab line setting

" Anywhere SID.
function! s:SID_PREFIX() " tentative
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
if empty(expand('<SID>'))
    let s:sid = s:SID_PREFIX()
else
    let s:sid = expand('<SID>')
endif

" Set tabline.
function! s:get_title(tabnr)
    let bufnrs = tabpagebuflist(a:tabnr)
    let bufnr = bufnrs[tabpagewinnr(a:tabnr)-1]
    let mod = getbufvar(bufnr, '&modified') ? '[+]' : ''
    let title = fnamemodify(bufname(bufnr), ':t')
    if getbufvar(bufnr, '&filetype') == 'qf'
        let title = "QuickFix"
    endif
    let title = '[' . title . ']'
    let title = a:tabnr . ':' . title . mod
    return title
endfunction

function! s:get_cwd_path()
    let max_dir_len = &columns/5
    let ret = pathshorten(getcwd())

    " ssh 先ではhostnameも表示
    if exists('$SSH_CLIENT')
        let hname = hostname()[:match(hostname(), '\.')-1] . ':'
    else
        let hname = ''
    endif

    " 長い場合は切る
    if len(ret)+len(hname) > max_dir_len
        let ret = '~~'.ret[-(max_dir_len-len(hname)-2):]
    endif

    return hname.ret
endfunction

function! s:set_tabline()
    let width = &columns
    let s = ''
    let cur_tab_no = tabpagenr()
    let all_files = 0
    let is_edit = 0
    let all_tabs = 0
    let tab_len = 0
    let tab_fin_l = 0
    let tab_fin_r = 0

    if meflib#get('show_cwd_tab', 1) == 1
        let cdir = ' @'.s:get_cwd_path()
        let tab_len += len(cdir)
    else
        let cdir = ''
    endif
    let debug = meflib#get('tab_debug', 0)
    if debug
        let str = ''
    endif

    " count listed & loaded buffers
    for bn in range(1, bufnr('$'))
        if buflisted(bn) && bufloaded(bn)
            let all_files += 1
            if getbufvar(bn, '&modified')
                let is_edit += 1
            endif
        endif
    endfor
    let all_tabs = tabpagenr('$')
    let header = printf('_%d/%d(%d)_ ', is_edit, all_files, all_tabs)
    let tab_len += len(header)

    " set footer
    let footer = meflib#get('tabline_footer', '')
    if !empty(footer)
        let [footer, len] = call(footer, [])
        let tab_len += len
    endif

    for i in range(1, tabpagenr('$'))
        " left side of current tab page (include current tab page).
        let ctn_l = cur_tab_no - (i-1)
        if debug
            let str .= printf("\n%d<=%d", ctn_l, cur_tab_no)
        endif
        if ctn_l > 0
            " add title to tabline if possible
            if tab_fin_l == 0
                if tab_len+1 < width || ctn_l == cur_tab_no " +1 .. ~
                    let title = s:get_title(ctn_l)
                    if debug
                        let str .= printf('  width: %d, tab_len: %d->%d', width, tab_len, tab_len+len(title)+1)
                    endif
                    if tab_len+len(title)+1+1 > width " +1=~
                        " cut the title if it is long.
                        let cut_length = len(title)-(width-tab_len-1-2-1) " -2=.., -1=~
                        " let cut_length = cut_length<0 ? 0 : cut_length
                        if cut_length > len(title)
                            let title = ''
                        else
                            let title = '..'.title[cut_length:]
                        endif
                        let tab_fin_l = 1
                        if debug
                            let str .= '  cut: '.cut_length.'; '.title
                        endif
                    endif
                    if !empty(title)
                        let tab_len += len(title)+1
                        let tmp_s = '%'.ctn_l.'T'
                        let tmp_s .= '%#' . (ctn_l == cur_tab_no ? 'TabLineSel' : 'TabLine') . '#'
                        let tmp_s .= title
                        let tmp_s .= '%#TabLineFill# '
                        let s = tmp_s.s
                    endif
                else
                    " finish to add the left side.
                    let tab_fin_l = 1
                endif
            endif
        endif

        " right side of current tab page.
        let ctn_r = cur_tab_no + i
        if debug
            let str .= printf("\n%d>%d", ctn_r, cur_tab_no)
        endif
        if ctn_r <= tabpagenr('$')
            " add title to tabline if possible
            if tab_fin_r == 0
                if tab_len+1 < width " +1 .. ~
                    let title = s:get_title(ctn_r)
                    if debug
                        let str .= printf('  width: %d, tab_len: %d->%d', width, tab_len, tab_len+len(title)+1)
                    endif
                    if tab_len+len(title)+1+1 > width " +1=[:X]の余剰
                        " cut the title if it is long.
                        let cut_length = width-tab_len-1-1-2 " -1=余剰, -2=..
                        if cut_length > 0
                            let title = title[:cut_length].'..'
                            if debug
                                let str .= '  cut: '.cut_length.'; '.title
                            endif
                        else
                            let title = ''
                            let s .= '~'
                            let tab_len += 1
                            if debug
                                let str .= 'cut all: '.cut_length
                            endif
                        endif
                        let tab_fin_r = 1
                    endif
                    if !empty(title)
                        let tab_len += len(title)+1
                        let tmp_s = '%'.ctn_r.'T'
                        let tmp_s .= '%#TabLine#'
                        let tmp_s .= title
                        let tmp_s .= '%#TabLineFill# '
                        let s .= tmp_s
                    endif
                else
                    " finish to add the right side.
                    let s .= '~'
                    let tab_len += 1
                    let tab_fin_r = 1
                endif
            endif
        endif
    endfor
    " color setting
    let header = '%#TabLineFill#'.header.'%#TabLineFill#'
    " 右寄せしてディレクトリ表示
    let footer = '%=%#TabLineDir#'.cdir.'%#TabLineFill#'.footer
    let s = header.s.footer
    if debug
        call meflib#set('tabinfo', str)
    endif
    return s
endfunction

let &tabline = '%!'..s:sid..'set_tabline()'
set showtabline=2 " 常にタブラインを表示

