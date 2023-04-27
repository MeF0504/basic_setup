
# pytree {{{
_pytree_completion()
{
    local cur prev
    cur=${COMP_WORDS[${COMP_CWORD}]}
    prev=${COMP_WORDS[${COMP_CWORD}-1]}

    local opts="-h -a -v -maxdepth -exclude -exfiles"
    if [[ "${cur:0:1}" = "-" ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    elif [[ "${prev}" = "-h" ]]; then
        # show help
        COMPREPLY=()
    elif [[ "${prev}" = "-exfiles" ]]; then
        # select file
        COMPREPLY=( $(compgen -f -- "$cur") )
    else
        # select dir
        compopt -o filenames
        COMPREPLY=( $(compgen -d -- "$cur") )
    fi
}
complete -F _pytree_completion pytree
# }}}

# pip bash completion start {{{
# https://pip.pypa.io/en/stable/user_guide/#command-completion
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 2>/dev/null ) )
}
complete -o default -F _pip_completion pip3
# pip bash completion end }}}

