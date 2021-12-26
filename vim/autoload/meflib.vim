"vim script encoding setting
scriptencoding utf-8

" wrapper of frequently used functions

function! meflib#set_local_var(var_name, var, ...) abort
    call call('meflib#basic#set_local_var', [a:var_name, a:var]+a:000)
endfunction

function! meflib#get_local_var(var_name, default) abort
    return meflib#basic#get_local_var(a:var_name, a:default)
endfunction

