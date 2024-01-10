
# -gをつけるとpipe や redirect のようなaliasも作れる
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc'
alias -g G='| grep -i'
alias -g L='| less -R'
alias -g TE=' 2>&1 | tee '
alias -g S='| sort'

local HIST_CMD="fc -l -n -t '%Y/%m/%d=%H:%M:%S' -D"
local VIM_HIST_CMD="vim -c 'setlocal bt=nofile | setlocal ft=zsh | match Comment /^.*  [0-9]\+:[0-9][0-9]  / | normal! G' -"
alias zshhistory="${HIST_CMD} -300 | ${VIM_HIST_CMD}"
alias zshhistory_all="echo 'please wait...' && ${HIST_CMD} 0 | ${VIM_HIST_CMD}"

