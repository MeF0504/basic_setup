"vim script encording setting
scriptencoding utf-8

" map系 {{{
" [[より[mの方が好み
" 頑張って]mとかを使うようにしよう...
" nmap <buffer> ]] ]m
" nmap <buffer> [[ [m
" nmap <buffer> ][ ]M
" nmap <buffer> [] [M

" if __name__ == \"__main__\" も ]] [[ の対象にしたい
let b:next_toplevel='\v%$\|^((class\|def\|async def)>\|if __name__ \=\=)'
let b:prev_toplevel='\v^((class\|def\|async def)>\|if __name__ \=\=)'
let s:ftp_py_map = maparg('[[', 'n', 0, 1)
if has_key(s:ftp_py_map, 'sid')
    execute printf("nnoremap <silent> <buffer> ]] :<C-U>call <SNR>%s_Python_jump('n', '%s', 'W', v:count1)<cr>",  s:ftp_py_map.sid, b:next_toplevel)
    execute printf("nnoremap <silent> <buffer> [[ :<C-U>call <SNR>%s_Python_jump('n', '%s', 'Wb', v:count1)<cr>", s:ftp_py_map.sid, b:prev_toplevel)
endif
" }}}

