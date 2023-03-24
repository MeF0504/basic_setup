get_term_name()
{
    # teminal で何を使っているのか判別する方法を忘れないように
    if [[ -n "${ITERM_SESSION_ID}" ]]; then
        echo 'iTerm.app'
    elif [[ -n "${TERMINATOR_UUID}" ]]; then
        echo 'Terminator'
    elif [[ -n "${TERMINOLOGY}" ]]; then
        echo 'Terminology'
    elif [[ -n "${WT_SESSION}" ]]; then
        echo 'Windows_Terminal'
    elif [[ -n "${TERM_PROGRAM}" ]]; then
        echo "${TERM_PROGRAM}"
    fi
}

