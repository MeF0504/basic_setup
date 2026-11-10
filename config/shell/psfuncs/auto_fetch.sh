auto_fetch()
{
    for DIR in $(echo ${FETCH_SKIP:-""}); do
        if [[ $(basename "$PWD") = $DIR ]]; then
            echo "skip fetching"
            return
        fi
    done
    local branch=$(git branch --contains | cut -d " " -f 2)
    echo "fetching..."
    git fetch
    echo
    git log --graph --oneline ${branch}..origin/${branch} \
        --date=format:"%Y/%m/%d" \
        --pretty=format:"%C(yellow)%h%Creset %C(green)%ad%Creset%C(auto)%d%Creset %s"
}
