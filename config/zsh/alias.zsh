
# -gをつけるとpipe や redirect のようなaliasも作れる
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc'
alias -g G='| grep -i'
alias -g L='| less -R'
alias -g TE=' 2>&1 | tee '
alias -g S='| sort'

alias zshhistory="fc -l -n -t '%Y/%m/%d %H:%M:%S' -D -300 | vim -c 'setlocal bt=nofile | setlocal ft=zsh' -"
alias zshhistory_all="fc -l -n -t '%Y/%m/%d %H:%M:%S' -D 0 | vim -c 'setlocal bt=nofile | setlocal ft=zsh' -"

