vimfind()
{
    # find file and open it by vim
    find "$@" > /dev/null && vim_wrapper $(find "$@")
}

