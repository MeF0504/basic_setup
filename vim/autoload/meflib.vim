"vim script encoding setting
scriptencoding utf-8

" wrapper of frequently used functions

function! meflib#set(var_name, var, ...) abort
    call call('meflib#basic#set_local_var', [a:var_name, a:var]+a:000)
endfunction

function! meflib#get(var_name, default, ...) abort
    return call('meflib#basic#get_local_var', [a:var_name, a:default]+a:000)
endfunction

function! meflib#add(var_name, var) abort
    return call('meflib#basic#add_local_var', [a:var_name, a:var])
endfunction

