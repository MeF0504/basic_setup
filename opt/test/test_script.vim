set number

" comment
function! s:test_func(val)
    let val = a:val

    if val == 1
        let is_one = 1
    else
        let is_one = 0
    endif
    if is_one == 1
        echo 'Hello, World!!'
    else
        return 0
    endif

endfunction

call s:test_func(1.3)

