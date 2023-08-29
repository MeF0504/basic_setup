" project内のファイル検索
PlugWrapper 'ctrlpvim/ctrlp.vim', PlugCond(1, {'on': 'CtrlP'})
"nnoremap <leader>s :<C-U>CtrlP<CR>
let g:ctrlp_map = '<leader>s'
nnoremap <leader>s <Cmd>CtrlP<CR>
let g:ctrlp_by_filename = 0
let g:ctrlp_match_window = 'order:ttb,min:1,max:7,results:15'
let g:ctrlp_switch_buffer = 'e'

let s:ctrlp_help_bufid = -1
let s:ctrlp_help_popid = -1
" {{{ help
let s:ctrlp_help = [
        \ "<c-d>: Toggle between full-path search and filename only search.",
        \ "<c-r>: Toggle between the string mode and full regexp mode.",
        \ "<c-f>, <c-up>  : Scroll to the 'next' search mode in the sequence.",
        \ "<c-b>, <c-down>: Scroll to the 'previous' search mode in the sequence.",
        \ "<tab>: Auto-complete directory names under the current working directory inside the prompt.",
        \ "<s-tab>: Toggle the focus between the match window and the prompt.",
        \ "<esc>, <c-c>: Exit CtrlP.",
        \ "<c-a>: Move the cursor to the 'start' of the prompt.",
        \ "<c-e>: Move the cursor to the 'end' of the prompt.",
        \ "<c-w>: Delete a preceding inner word.",
        \ "<c-u>: Clear the input field.",
        \ "<c-n>: Next string in the prompt's history.",
        \ "<c-p>: Previous string in the prompt's history.",
        \ "<cr>:  Open the selected file in the 'current' window if possible.",
        \ "<c-t>: Open the selected file in a new 'tab'.",
        \ "<c-v>: Open the selected file in a 'vertical' split.",
        \ "<c-x>: Open the selected file in a 'horizontal' split.",
        \ "<c-y>: Create a new file and its parent directories.",
        \ ]
" }}}
function! <SID>show_ctrlp_help()
    if s:ctrlp_help_popid != -1
        call meflib#floating#close(s:ctrlp_help_popid)
        let s:ctrlp_help_popid = -1
        return
    endif
    let config = {
        \ 'relative': 'editor',
        \ 'line': &lines-7-&cmdheight-2,
        \ 'col': &columns-3,
        \ 'pos': 'botright',
        \ }
    let [s:ctrlp_help_bufid, s:ctrlp_help_popid] = meflib#floating#open(s:ctrlp_help_bufid, s:ctrlp_help_popid, s:ctrlp_help, config)
endfunction
function! <SID>echo_ctrlp_help() abort
    for str in s:ctrlp_help
        echo str
    endfor
endfunction
if has('nvim')
    " なんかfloating windowがコケる
    autocmd PlugLocal FileType ctrlp ++once nnoremap <buffer> <silent> ? <Cmd>call <SID>echo_ctrlp_help()<CR>
else
    autocmd PlugLocal FileType ctrlp ++once nnoremap <buffer> <silent> ? <Cmd>call <SID>show_ctrlp_help()<CR>
endif

