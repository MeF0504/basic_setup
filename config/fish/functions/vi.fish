function vi --description 'vi/vim wrapper'
    if [ -n "$_USED_VIM" ]
        set use_vim $_USED_VIM
    else
        set use_vim 'vim'
    end
    $use_vim -p $argv
end

