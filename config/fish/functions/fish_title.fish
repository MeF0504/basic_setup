function fish_title --description 'set titme'
    if [ -n "$SSH_CLIENT$SSH_CONNECTION" ]
        set curdir $hostname
    else if [ $PWD = $HOME ]
        set curdir 'home'
    else
        set curdir (basename $PWD)
    end
    printf "%s%s@%s%s" \U1f41f $USER $curdir \U1f41f
end
