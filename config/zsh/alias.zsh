
# -gをつけるとpipe や redirect のようなaliasも作れる
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc'
alias -g G='| grep -i'
alias -g L='| less -R'
alias -g TE=' 2>&1 | tee '
alias -g S='| sort'

alias zshhistory="cat $HISTFILE | vim -c 'setlocal bt=nofile | setlocal ft=zsh' -"

