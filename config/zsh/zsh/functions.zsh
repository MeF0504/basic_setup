
#check the terminal can display 256colors
function _256colortest()
{
    local code
    for code in {0..255}; do
        echo -e "\e[38;05;${code}m $code: Test"
    done
}
alias 256colortest="_256colortest | less -R"

# grep from all git repository
# https://qiita.com/yuba/items/852d019af48ee7ccd92e
function git_grep()
{
    ## option of uniq is different btw mac and linux?
    if [ "$(uname)" = "Darwin" ]; then
        git grep $1 $(git branch -a --format='%(objectname) %(refname:short)' | sort | uniq -s 40 | cut -c 42-)
    elif [ "$(uname)" = "Linux" ]; then
        git grep $1 $(git branch -a --format='%(objectname) %(refname:short)' | sort | uniq -w 40 | cut -c 42-)
    fi
}

if which wsh &>/dev/null; then
    # open a html file using wsh web.
    function wsh-web() {
        if [ -z "$1" ]; then
            echo "open a html file using wsh web."
            echo "Usage: wsh-web <file>"
            return 1
        fi
        wsh web open "file://${PWD}/$1"
    }
else
fi

# smart? history
zshhistory()
{
    local HIST_CMD="fc"

    if builtin command -v $HIST_CMD >/dev/null 2>&1; then
        ;
    else
        echo "${HIST_CMD} command is not found."
        return 1
    fi

    if [[ $1 == -[0-9]* ]]; then
        local num=$1
    elif [[ $1 == "--all" ]]; then
        local num="0"
    elif [[ -z "$1" ]]; then
        local num="-100"
    else
        echo "usage: zshhistory [-N | --all]"
        return 1
    fi

    ${HIST_CMD} -l -n -t '%Y/%m/%d=%H:%M:%S' -D ${num} | ${_USE_VIM} -c 'setlocal bt=nofile | setlocal ft=zsh | match Comment /^.*  [0-9]\+:[0-9][0-9]  / | normal! G' -
}

