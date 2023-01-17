scriptencoding utf-8

let s:statusline = meflib#get('statusline', 'qf', '')
if !empty(s:statusline)
    " rewrite
    call setwinvar(win_getid(), "&statusline", s:statusline)
endif
