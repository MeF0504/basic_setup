vimman()
{
    # open manual in vim
    # https://rcmdnk.com/blog/2014/07/20/computer-vim/
    man "$@" 2>&1 | col -bx | vim_wrapper -R -c 'set ft=man nolist nomod noma' -
}

