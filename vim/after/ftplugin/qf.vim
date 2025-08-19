scriptencoding utf-8

"See $VIMRUNTIME/ftplugin/qf.vim to change quickfix window statusline
let s:statusline = meflib#get('statusline', 'qf', '')
if !empty(s:statusline)
    " rewrite
    call setwinvar(win_getid(), "&statusline", s:statusline)
endif
