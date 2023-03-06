scriptencoding utf-8

" Jで\を消す
function! meflib#join_wrapper#main() abort
    " https://zenn.dev/kawarimidoll/articles/7ae1e7a485d882
    let from = line('v')
    let to = line('.')
    if from == to
        let to += 1
    endif
    " echomsg from..' - '..to
    let pattern = ''
    let sla = ''
    if match(getline(from, to), '^.*\\s*$') != -1
        " ends with \
        let sla = 'end'
        let pattern = '/^.*\zs\\s*//'
    elseif match(getline(from, to), '^\s*\\s*.*$') != -1
        " starts with \
        let sla = 'start'
        let pattern = '/^\s*\\s*//'
    endif
    " echomsg 'sla='..sla

    let mode = mode()
    if mode ==# 'n'
        if sla ==# 'end'
            let range = from
        elseif sla ==# 'start'
            let range = from+1
        else
            " sla is empty => pattern is empty. do not used.
        endif
    else
        " visual mode
        if sla ==# 'end'
            let range = printf('%s,%s', from, to-1)
        elseif sla ==# 'start'
            let range = printf('%s,%s', from+1, to)
        else
            " sla is empty => pattern is empty. do not used.
        endif
    endif
    if !empty(pattern)
        execute printf('silent! %ssubstitute%s', range, pattern)
    endif

    if mode ==# 'n'
        execute printf('keepjump normal! %sGJ', from)
    else
        " visual mode
        " already selected.
        normal! J
    endif
endfunction

