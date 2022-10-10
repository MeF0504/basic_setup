function findvim --description 'open found file in vim.'
    if [ -n "$_USED_VIM" ]
        set use_vim $_USED_VIM
    else
        set use_vim 'vim'
    end
    $use_vim -p $(find $argv)
end

