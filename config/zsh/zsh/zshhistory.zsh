#! /bin/zsh

local HIST_CMD="fc"

if builtin command -v $HIST_CMD >/dev/null 2>&1; then
    ;
else
    echo "${HIST_CMD} command is not found."
    return 1
fi

if [[ $1 == -[0-9]* ]]; then
    num=$1
elif [[ $1 == "--all" ]]; then
    num="0"
elif [[ -z "$1" ]]; then
    num="-100"
else
    echo "usage: zshhistory [-N | --all]"
    return 1
fi

${HIST_CMD} -l -n -t '%Y/%m/%d=%H:%M:%S' -D ${num} | ${_USE_VIM} -c 'setlocal bt=nofile | setlocal ft=zsh | match Comment /^.*  [0-9]\+:[0-9][0-9]  / | normal! G' -
