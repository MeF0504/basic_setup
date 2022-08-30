# https://natsukium.github.io/fish-docs-jp/index.html
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# environmental variables {{{
# ls
export LSCOLORS=Exfxcxdxbxegedabagbcbd
# }}}

# alias (copy from posixShellRC) {{{
alias where="command -v"
alias j="jobs -l"
# ls
switch (uname)
case FreeBSD or Darwin
    alias ls="ls -G -w"
case Linux
    alias ls="ls --color -F"
end
alias la="ls -a"
alias lf="ls -F"
alias ll="ls -l"

# shortcut
alias l="ls"
alias c="cd"

# check if already exists
alias cp="cp -i"
alias mv="mv -i"

# make directory recursively
alias mkdir="mkdir -p"

# change the unit
alias du="du -h"
alias df="df -h"

alias su="su -l"
alias grep="grep --color"

# vim
alias vi='vim -p'

# move files to trash.
alias del="mv_Trash.py"

if string length -q -- $SSH_CLIENT
    alias su='echo "su is not available in remote host"'
    alias sudo='echo "sudo is not available in remote host"&&'
end

# OS specified aliases
switch (uname)
case Darwin
    alias ldd="echo 'in macOS, ldd doesn't exist. && echo 'Use otool -L instead.' && echo '----------' &&  otool -L"
case Linux
end
# }}}

# Fish git prompt {{{
# https://www.cyokodog.net/blog/fish-based-terminal-environment/
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red
 
# Status Chars
set __fish_git_prompt_char_dirtystate '⚡' # '*'
set __fish_git_prompt_char_stagedstate '+'
set __fish_git_prompt_char_untrackedfiles '?'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'
# }}}

