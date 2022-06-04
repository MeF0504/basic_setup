
if ps -p $$ | grep -qs "\(zsh\|bash\)" ; then
    if ps -p $$ | grep -qs "zsh" ; then
        export PROMPT="$ "
        tab_title_precmd()
        {
            echo -ne "\033]0;~zsh~\007"
        }
    elif ps -p $$ | grep -qs "bash" ; then
        export PS1="$ "
        echo -ne "\033]0;~bash~\a"
    fi
else
    echo "not supported shell."
fi
