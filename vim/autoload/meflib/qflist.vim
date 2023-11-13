scriptencoding utf-8

" https://zenn.dev/vim_jp/articles/f23938c7df2dd9
function! s:open_qf_cb(nmax, wid, res) abort
    if a:res <= 0
        return
    endif
    execute (a:nmax-a:res+1)..'chistory'
    copen
endfunction

function! meflib#qflist#main() abort
    let qf_list = []
    for i in range(10)
        let item = getqflist({'nr': i+1, 'title': v:true})
        if item.nr <= 0
            break
        endif
        call insert(qf_list, item.title)
    endfor
    if empty(qf_list)
        echo 'quick fix list is empty.'
        return
    endif
    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines/3,
                \ 'col': &columns-2,
                \ 'nv_border': 'single',
                \ }
    call meflib#floating#select(qf_list, config,
                \function(expand('<SID>')..'open_qf_cb', [len(qf_list)]))
endfunction
