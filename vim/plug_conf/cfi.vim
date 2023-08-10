" current lineの関数表示用plugin (StatusLine用)
Plug 'tyru/current-func-info.vim'
" autocmd PlugLocal User current-func-info.vim call s:cfi_hook()
autocmd PlugLocal VimEnter * call s:cfi_hook()
" highlights
function! <SID>cfi_his() abort
    highlight default CFIPopup ctermbg=11 ctermfg=233 cterm=bold guibg=Yellow guifg=#121212 gui=Bold
endfunction
call meflib#add('plugin_his', expand('<SID>').'cfi_his')

let s:cfi_bufid = -1
let s:cfi_popid = -1
function! <SID>Show_cfi()
    if meflib#basic#get_local_var('cfi_on', 0) == 0
        call meflib#floating#close(s:cfi_popid)
        let s:cfi_popid = -1
        return
    endif
    if cfi#supported_filetype(&filetype) == 0
        return
    endif
    if has('nvim')
        let line = 0
    else
        let line = 1
    endif
    " let cfi = cfi#get_func_name()
    let cfi = cfi#format("%s()", "Top")
    let config = {
        \ 'relative': 'win',
        \ 'line': line,
        \ 'col': winwidth(0),
        \ 'pos': 'topright',
        \ 'highlight': 'CFIPopup',
        \ }
    let [s:cfi_bufid, s:cfi_popid] = meflib#floating#open(s:cfi_bufid, s:cfi_popid, [cfi], config)
endfunction
function! s:cfi_hook() abort
    if !exists('g:loaded_cfi')
        return
    endif
    autocmd PlugLocal CursorMoved * call <SID>Show_cfi()
    " to close in terminal window
    autocmd PlugLocal BufEnter * call meflib#floating#close(s:cfi_popid) | let s:cfi_popid=-1
    autocmd PlugLocal WinLeave * call meflib#floating#close(s:cfi_popid) | let s:cfi_popid=-1
    autocmd PlugLocal QuitPre * call meflib#floating#close(s:cfi_popid) | let s:cfi_popid=-1
endfunction

