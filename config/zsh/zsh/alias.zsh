
# -gをつけるとpipe や redirect のようなaliasも作れる
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc'
alias -g G='| grep -i'
alias -g L='| less -R'
alias -g TE=' 2>&1 | tee '
alias -g S='| sort'
# ファイル探索からVimにつなぐ。xargsの中だとaliasが効かない？
alias -g V='| xargs -o vim -p'

alias zshhistory="source ${HOME}/.zsh/zshhistory.zsh"

