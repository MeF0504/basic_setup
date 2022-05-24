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
    let header = '..'
    let footer = '>'..tabpagenr('$')
    let all_files = 0
    let all_wins = 0
    let is_edit = 0
    let tab_len = 17 " max(header + footer) = 12+2+3
    let tab_fin_l = 0
    let tab_fin_r = 0

    if meflib#get_local_var('show_cwd_tab', 1) == 1
        let cdir = ' @'.s:get_cwd_path()
        let tab_len += len(cdir)
    else
        let cdir = ''
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

    for i in range(1, tabpagenr('$'))
        " left side of current tab page (include current tab page).
        let ctn_l = cur_tab_no - (i-1)
        if ctn_l > 0
            " count windows
            let all_wins += tabpagewinnr(ctn_l, '$')
            " add title to tabline if possible
            if tab_fin_l == 0
                let title = s:get_title(ctn_l)
                if tab_len+len(title)+1 < width || ctn_l == cur_tab_no
                    let tab_len += len(title)+1
                    let tmp_s = '%'.ctn_l.'T'
                    let tmp_s .= '%#' . (ctn_l == cur_tab_no ? 'TabLineSel' : 'TabLine') . '#'
                    let tmp_s .= title
                    let tmp_s .= '%#TabLineFill# '
                    let s = tmp_s.s
                    " set header & footer
                    if ctn_l == 1
                        let header = ''
                    endif
                    if ctn_l == tabpagenr('$')
                        let footer = ''
                    endif
                else
                    " finish to add the left side.
                    let tab_fin_l = 1
                endif
            endif
        endif

        " right side if current tab page.
        let ctn_r = cur_tab_no + i
        if ctn_r <= tabpagenr('$')
            " count windows
            let all_wins += tabpagewinnr(ctn_r, '$')
            " add title to tabline if possible
            if tab_fin_r == 0
                if tab_len+1 < width
                    let title = s:get_title(ctn_r)
                    if tab_len+len(title)+1 > width
                        " cut the title if it is long.
                        let title = title[:width-tab_len-3].'..'
                        let tab_fin_l = 1
                    endif
                    let tab_len += len(title)+1
                    let tmp_s = '%'.ctn_r.'T'
                    let tmp_s .= '%#TabLine#'
                    let tmp_s .= title
                    let tmp_s .= '%#TabLineFill# '
                    let s .= tmp_s
                    " set footer
                    if ctn_r == tabpagenr('$')
                        let footer = ''
                    endif
                else
                    " finish to add the right side.
                    let tab_fin_r = 1
                endif
            endif
        endif
    endfor
    let header = '_'.is_edit.'/'.all_files.'('.all_wins.')_ ' . header
    " color setting
    let header = '%#TabLineFill#'.header.'%#TabLineFill#'
    " color setting
    let footer = '%#TabLineFill#'.footer.'%#TabLineFill#'
    " 右寄せしてディレクトリ表示
    let rtabline = '%=%#TabLineDir#'.cdir.'%#TabLineFill#'
    let s = header.s.footer.rtabline
    return s
endfunction

let &tabline = '%!'..s:sid..'set_tabline()'
set showtabline=2 " 常にタブラインを表示

