calc()
{
    # here document?
    # bc -l <<< "$@"
    echo $(($@))
}

