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
    if &filetype == 'markdown'
        " https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one
        let cmd = 'markdown.showPreviewToSide'
    elseif &filetype == 'tex'
        " 細かい設定はlatex-workshop.latex.recipesとtoolsをいじってくれなのだ
        " https://texwiki.texjp.org/?Visual%20Studio%20Code%2FLaTeX
        " https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop
        let cmd = 'latex-workshop.build'
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

" highlighter {{{
" https://marketplace.visualstudio.com/items?itemName=ryu1kn.text-marker
nnoremap // <Cmd>call VSCodeNotify('textmarker.toggleHighlight')<CR>
vnoremap // <Cmd>call VSCodeNotifyVisual('textmarker.toggleHighlight', 0)<CR>
" }}}

