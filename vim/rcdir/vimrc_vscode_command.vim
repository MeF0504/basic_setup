" vim script encoding setting
scriptencoding utf-8
"" vim commands for VS code.
" https://code.visualstudio.com/api/references/commands
" https://code.visualstudio.com/docs/getstarted/keybindings

if !exists('g:vscode')
    finish
endif

" vim searching overwapping {{{
nnoremap / <Cmd>call VSCodeNotify('actions.find')<CR>
nnoremap n <Cmd>call VSCodeNotify('editor.action.nextMatchFindAction')<CR>
nnoremap N <Cmd>call VSCodeNotify('editor.action.previousMatchFindAction')<CR>
" }}}

" user defined commands {{{
command! -nargs=0 Gregrep call VSCodeNotify('workbench.action.findInFiles')

command! Terminal call VSCodeNotify('workbench.action.terminal.new')

command! QuickRun call VSCodeNotify('workbench.action.debug.start')
nmap <leader>q <Cmd>QuickRun<CR>

command! Replace call VSCodeNotify('editor.action.startFindReplaceAction')
" }}}
