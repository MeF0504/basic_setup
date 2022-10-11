"vim script encoding setting
scriptencoding utf-8

" wrapper of frequently used functions

function! meflib#set(var_name, var, key='') abort
    call call('meflib#basic#set_local_var', [a:var_name, a:var, a:key])
endfunction

function! meflib#get(var_name, default, key='') abort
    return call('meflib#basic#get_local_var', [a:var_name, a:default, a:key])
endfunction

function! meflib#add(var_name, var) abort
    return call('meflib#basic#add_local_var', [a:var_name, a:var])
endfunction

