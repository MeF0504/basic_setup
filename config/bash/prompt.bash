
# useful: https://qiita.com/hmmrjn/items/60d2a64c9e5bf7c0fe60
# color & format: https://misc.flogisoft.com/bash/tip_colors_and_formatting
# path
_PS_PATH='\[\e[97m\]\[\e[44m\]${PWD}\[\e[0m\]'
if [[ -n "${SSH_CLIENT}${SSH_CONNECTION}" ]]; then
    # host name
    _PS_HOST='\[\e[36m\]${HOSTNAME%%.*}\[\e[0m\] '
fi
_PS_COUNTFILE='(`ls -U1 | wc -l | sed -e "s/ //g"`)'
# time
_PS_TIME='\[\e[92m\]\D{%H:%M}\[\e[0m\]'
# user name (bold)
_PS_USER=' \[\e[1m\e[31m\]\u\[\e[0m\]'
# background job number
# _PS_BGJOB=' \[\e[105m\](J:\j)\[\e[0m\]'
_PS_BGJOB='`
if [ -z "$(jobs)" ]; then
    echo "";
else
    echo " \[\e[105m\](J:\j)\[\e[0m\]";
fi
`'

# git information
GITPROMPT="${HOME}/.bash/git-prompt.sh"
if [[ -f "$GITPROMPT" ]]; then
    # unstaged (*) and staged (+) are shown
    export GIT_PS1_SHOWDIRTYSTATE=1
    source "$GITPROMPT"
    _PS_GIT='$(__git_ps1 " (%s)")'
fi

# change red if the previous command was failed.
# https://qiita.com/rtakasuke/items/4b50e156ab82b0824676
_PS_END=" $ "

case $(date "+%w") in
0)
    _PS_SHCOL="\e[100m"
    ;;
1)
    _PS_SHCOL="\e[45m"
    ;;
2)
    _PS_SHCOL="\e[101m"
    ;;
3)
    _PS_SHCOL="\e[44m"
    ;;
4)
    _PS_SHCOL="\e[42m"
    ;;
5)
    _PS_SHCOL="\e[43m"
    ;;
6)
    _PS_SHCOL="\e[40m"
    ;;
esac
_PS_SHINFO="\`
if [ \$? = 0 ]; then
    echo '\[\e[97m\]\[${_PS_SHCOL}\][${SHELL_INFO}]\[\e[0m\] ';
else
    echo '\[\e[90m\]\[${_PS_SHCOL}\][${SHELL_INFO}]\[\e[0m\] ';
fi
\`"
# "

export PS1="${_PS_SHINFO}${_PS_HOST}${_PS_PATH}${_PS_COUNTFILE}\n${_PS_TIME}${_PS_USER}${_PS_BGJOB}${_PS_GIT}${_PS_END}"

