scriptencoding utf-8

if has('nvim-0.10')
    function! s:report_info(msg) abort
        call v:lua.vim.health.info(a:msg)
    endfunction
    function! s:report_ok(msg) abort
        call v:lua.vim.health.ok(a:msg)
    endfunction
    function! s:report_warn(msg) abort
        call v:lua.vim.health.warn(a:msg)
    endfunction
    function! s:report_error(msg) abort
        call v:lua.vim.health.error(a:msg)
    endfunction
else
    function! s:report_info(msg) abort
        call health#report_info(a:msg)
    endfunction
    function! s:report_ok(msg) abort
        call health#report_ok(a:msg)
    endfunction
    function! s:report_warn(msg) abort
        call health#report_warn(a:msg)
    endfunction
    function! s:report_error(msg) abort
        call health#report_error(a:msg)
    endfunction
endif

function! health#meflib#check() abort
    if executable('python3')
        let python_path = exepath('python3')
        call s:report_ok(printf(
                    \ 'python3 is executable: %s',
                    \ python_path))
        call s:report_info(printf(
                    \ 'version: %s',
                    \ system('python3 -V')->substitute('\n', '', 'g')))
    else
        call s:report_error('python3 is not executable')
    endif
endfunction

