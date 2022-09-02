function fish_title
    if [ $PWD = $HOME ]
        set curdir 'home'
    else
        set curdir (basename $PWD)
    end
    printf "%s@%s" $USER $curdir
end
