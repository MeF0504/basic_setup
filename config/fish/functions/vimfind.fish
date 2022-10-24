function vimfind --description 'open found files in vim.'
    if [ -n "$_USED_VIM" ]
        set use_vim $_USED_VIM
    else
        set use_vim 'vim'
    end
    find $argv > /dev/null && $use_vim -p $(find $argv)
end

