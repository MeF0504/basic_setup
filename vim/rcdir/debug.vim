
" http://webtech-walker.com/archive/2010/04/27173007.html
let g:l_log = ''
function! LocalDebug(string) abort
    let g:l_log .= a:string."\n"

    let ld_exist = 0
    for bn in tabpagebuflist()
        if bufname(bn) == 'LocalDebug'
            let wids = win_findbuf(bn)
            call win_gotoid(wids[0])
            let ld_exist = 1
        endif
    endfor

    if ld_exist == 0
        vertical split LocalDebug
        setlocal noswapfile
        setlocal nobackup
        setlocal noundofile
        setlocal buftype=nofile
        setlocal nobuflisted
        setlocal nofoldenable
    endif

    1,$delete _
    silent put =g:l_log
    1,1delete _

    wincmd p
endfunction
