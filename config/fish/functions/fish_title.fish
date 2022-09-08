function fish_title --description 'set titme'
    if [ $PWD = $HOME ]
        set curdir 'home'
    else
        set curdir (basename $PWD)
    end
    printf "%s%s@%s%s" \U1f41f $USER $curdir \U1f41f
end
