scriptencoding utf-8

" packadd-ing plugins

function! s:packadd_plugin(plugin_name, bang) abort
    if exists('g:loaded_' . a:plugin_name)
        return
    endif
    if a:bang
        let cmd = 'packadd! ' . a:plugin_name
    else
        let cmd = 'packadd ' . a:plugin_name
    endif
    try
        execute cmd
    catch /E919/
        echomsg "@ vimrc_pack: " .. a:plugin_name .. ' not found.'
    endtry
endfunction
" editorconfig {{{
" nvim はpackaddしなくてもeditorconfig 入っているっぽい
if !has('nvim')
    call s:packadd_plugin('editorconfig', v:true)
endif
" }}}
