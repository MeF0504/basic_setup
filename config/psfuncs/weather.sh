weather()
{
    # Tokyo, Sapporo, SanFrancisco, moon, etc..
    if [[ "$1" =~ "-h" ]]; then
        echo "usage: weather city"
        echo "e.g. 'weather Tokyo', 'weather America California', 'weather moon' etc."
        return
    fi
    local city=$1
    for x in "${@:2}"; do
        city=$city+$x
    done
    curl wttr.in/"$city"
}

