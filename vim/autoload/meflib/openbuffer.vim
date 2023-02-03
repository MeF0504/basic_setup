scriptencoding utf-8

" buffer を選んでtabで開く
function! s:open_buffer_cb(mod, bang, wid, res) abort
    if a:res > 0
        if empty(a:mod)
            let mod = 'tab'
        else
            let mod = a:mod
        endif
        if a:bang ==# '!'
            let bufnr = a:res
            if getbufvar(bufnr, '&buftype') == 'popup'
                echo 'unable to open popup window'
                return
            endif
        else
            let bufnr = bufnr(s:bufs[a:res-1])
            if s:bufs[a:res-1] ==# '[No Name]' || bufnr <= 0
                echo 'No Name buffer is not supported yet.'
                return
            endif
        endif
        execute printf('%s %dsbuffer', mod, bufnr)
    endif
    unlet s:bufs
endfunction

function! meflib#openbuffer#main(mod, bang) abort
    let s:bufs = []
    for i in range(1, bufnr('$'))
        if a:bang==#'!' || buflisted(i)
            let bname = bufname(i)
            if empty(bname)
                let buftype = getbufvar(i, '&buftype')
                if buftype == 'nofile'
                    let bname = '[Scratch]'
                elseif buftype == 'popup'
                    let bname = '[Popup]'
                elseif buftype == 'prompt'
                    let bname = '[Prompt]'
                else
                    let bname = '[No Name]'
                endif
            endif
            call add(s:bufs, bname)
        endif
    endfor
    if empty(s:bufs)
        echo 'No buffer'
        return
    endif
    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines/3,
                \ 'col': &columns/3,
                \ 'nv_border': 'single',
                \ }
    call meflib#floating#select(s:bufs, config,
                \ function(expand('<SID>')..'open_buffer_cb', [a:mod, a:bang]))
endfunction

