scriptencoding utf-8


function! s:c_jump(pattern, count, flags)
    let cnt = a:count
    let ln = 0
    while cnt > 0
        let ln = search(a:pattern, a:flags)
        let cnt = cnt - 1
    endwhile
    if ln == 0
        normal! gg
        normal! ^
    endif
endfunction

nnoremap <buffer> [[ <Cmd>call <SID>c_jump('^\S.*{\\|^{', v:count1, 'Wb')<CR>
