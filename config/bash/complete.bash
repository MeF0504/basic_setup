
# https://atmarkit.itmedia.co.jp/ait/articles/1907/12/news015.html
# https://blog.cybozu.io/entry/2016/09/26/080000

# pip bash completion start
# https://pip.pypa.io/en/stable/user_guide/#command-completion
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 2>/dev/null ) )
}
complete -o default -F _pip_completion pip3
# pip bash completion end

