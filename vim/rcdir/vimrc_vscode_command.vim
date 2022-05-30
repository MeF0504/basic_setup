" vim script encoding setting
scriptencoding utf-8
"" vim commands for VS code.
" https://code.visualstudio.com/api/references/commands
" https://code.visualstudio.com/docs/getstarted/keybindings

if !exists('g:vscode')
    finish
endif

set foldcolumn=0

" vim searching overwapping {{{
nnoremap n <Cmd>call VSCodeNotify('editor.action.nextMatchFindAction')<CR>
nnoremap N <Cmd>call VSCodeNotify('editor.action.previousMatchFindAction')<CR>
" }}}

" {{{ undo/redo
nnoremap u <Cmd>call VSCodeNotify('undo')<CR>
nnoremap <c-r> <Cmd>call VSCodeNotify('redo')<CR>
" }}}

" user defined commands {{{
command! -nargs=0 Gregrep call VSCodeNotify('workbench.action.findInFiles')

command! Terminal call VSCodeNotify('workbench.action.terminal.new')

command! QuickRun call VSCodeNotify('workbench.action.debug.start')
function! <SID>quickrun_wrapper() abort
    " texは，後で自動buildを切って，build dir指定とかをやりたい。
    " launch.jsonを作ればうまくいくか？
    if &filetype == 'markdown'
        let cmd = 'markdown.showPreviewToSide'
    else
        let cmd = 'workbench.action.debug.start'
    endif
    call VSCodeNotify(cmd)
endfunction
nmap <leader>q <Cmd>call <SID>quickrun_wrapper()<CR>

command! Replace call VSCodeNotify('editor.action.startFindReplaceAction')
" }}}

" commentary-like map {{{
nnoremap gcc <Cmd>call VSCodeNotify('editor.action.commentLine')<CR>
vnoremap gc <Cmd>call VSCodeNotifyVisual('editor.action.commentLine', 0)<CR>
" }}}

