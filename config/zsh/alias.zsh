# expand aliases before completing
#
setopt complete_aliases     # aliased ls needs if file/dir completions work

alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc'
alias -g G='| grep -i'
alias -g L='| less -R'
alias -g TE=' 2>&1 | tee '

alias zshhistory="vi -R ~/.zsh_history"

