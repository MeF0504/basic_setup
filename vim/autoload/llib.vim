"vim script encording setting
scriptencoding utf-8

" get vim config directory
function! llib#get_conf_dir()
    if has('nvim')
        if exists("$XDG_CONFIG_HOME")
            let vimdir = expand($XDG_CONFIG_HOME . "/nvim/")
        else
            let vimdir = expand('~/.config/nvim/')
        endif
    else
        if has('win32')
            let vimdir = expand('~/vimfiles/')
        else
            let vimdir = expand('~/.vim/')
        endif
    endif

    return vimdir
endfunction

