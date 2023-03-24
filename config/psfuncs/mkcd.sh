mkcd()
{
    if [[ ! -d "$1" ]]; then
        echo mkdir "$1"
        mkdir -p "$1"
    fi
    \cd "$1"
}

