"vim script encoding setting
scriptencoding utf-8

" wrapper of frequently used functions

function! meflib#set(var_name, args1, args2=v:null) abort
    call call('meflib#basic#set_local_var', [a:var_name, a:args1, a:args2])
endfunction

function! meflib#get(var_name, args1, args2=v:null) abort
    return call('meflib#basic#get_local_var', [a:var_name, a:args1, a:args2])
endfunction

function! meflib#add(var_name, var) abort
    return call('meflib#basic#add_local_var', [a:var_name, a:var])
endfunction

