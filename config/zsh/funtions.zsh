
#check the terminal can display 256colors
function 256colortest() {
    local code
    for code in {0..255}; do
        echo -e "\e[38;05;${code}m $code: Test"
    done
}
alias 256colortest="256colortest | less -R"

# grep from all git repository
# https://qiita.com/yuba/items/852d019af48ee7ccd92e
function git_grep() {
    ## option of uniq is different btw mac and linux?
    if [ "$(uname)" = "Darwin" ]; then
        git grep $1 $(git branch -a --format='%(objectname) %(refname:short)' | sort | uniq -s 40 | cut -c 42-)
    elif [ "$(uname)" = "Linux" ]; then
        git grep $1 $(git branch -a --format='%(objectname) %(refname:short)' | sort | uniq -w 40 | cut -c 42-)
    fi
}

