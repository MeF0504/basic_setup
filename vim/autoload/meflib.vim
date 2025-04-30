"vim script encoding setting
scriptencoding utf-8

" wrapper of frequently used functions

" DOC FUNCTIONS meflib#set()
" meflib#set({var_name}, {args1}, {args2}=v:null)
"
" Set local variable.
" if {args2} is not null, set {args1} as key and {args2} as value.
" See |meflib-options| for available options.
" DOCEND
function! meflib#set(var_name, args1, args2=v:null) abort
    call call('meflib#basic#set_local_var', [a:var_name, a:args1, a:args2])
endfunction

" DOC FUNCTIONS meflib#get()
" meflib#get({var_name}, {args1}, {args2}=v:null)
"
" Get local variable.
" if {args2} is not null, set {args1} as key and {args2} as default value.
" otherwise, return set {args1} as default value.
" if {var_name} or key is not found, return default value.
" DOCEND
function! meflib#get(var_name, args1, args2=v:null) abort
    return call('meflib#basic#get_local_var', [a:var_name, a:args1, a:args2])
endfunction

" DOC FUNCTIONS meflib#add()
" meflib#add({var_name}, {var})
" 
" Add {value} to |list| of {var_name}. If {var_name} does not exist, make the list.
" DOCEND
function! meflib#add(var_name, var) abort
    return call('meflib#basic#add_local_var', [a:var_name, a:var])
endfunction

