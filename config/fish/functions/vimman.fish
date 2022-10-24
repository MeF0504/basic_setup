function vimman --description 'show manual in vim'
    if [ -n "$_USED_VIM" ]
        set use_vim $_USED_VIM
    else
        set use_vim 'vim'
    end
    man $argv 2>&1 | col -bx | $use_vim -R -c 'set ft=man nolist nomod noma' -
end


