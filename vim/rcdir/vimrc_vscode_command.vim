" vim script encoding setting
scriptencoding utf-8
"" vim commands for VS code.

if !exists('g:vscode')
    finish
endif

command! -nargs=0 Gregrep call VSCodeNotify('workbench.action.findInFiles')

