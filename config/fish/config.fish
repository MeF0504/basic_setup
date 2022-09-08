# https://natsukium.github.io/fish-docs-jp/index.html
# http://fish.rubikitch.com/
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# environmental variables {{{
# ls
set LSCOLORS Exfxcxdxbxegedabagbcbd
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

if [ -n "$SSH_CLIENT" ]
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

# cdした際の自動関数 {{{
function _auto_cd --on-event fish_postexec
    set _last_status $status
    if [ -z (string match -r '^\s*cd\s' $argv) ]
        # 引数なしでも弾かれるけど，今はまぁいいや
        return
    end
    if [ $_last_status -gt 0 ]
        # エラーの場合は何もしない
        return
    end

    if [ -d "$PWD/.git" ]
        read -p 'echo "execute fetch? ([y]/n) "' yn
        if [ -z "$yn" -o "$yn" = 'y' ]
            echo "fetching..."
            git fetch
        end
    end
end
# }}}

# Terminal 関連 {{{
if [ -n "$ITERM_SESSION_ID" ]
    # 特定コマンドでitermのtab colorを変換 {{{
    function tab_color
        set RGB (string split ' ' $argv)
        set R $RGB[1]
        set G $RGB[2]
        set B $RGB[3]
        echo -ne "\033]6;1;bg;red;brightness;$R\a"
        echo -ne "\033]6;1;bg;green;brightness;$G\a"
        echo -ne "\033]6;1;bg;blue;brightness;$B\a"
    end

    function tab_reset
        echo -ne "\033]6;1;bg;*;default\a"
    end

    function iterm2_tab_post --on-event fish_postexec
        tab_reset
    end

    function iterm2_tab_pre --on-event fish_preexec
        # sample set TABS '0 255 0 ^\s*ssh hoge' '128 128 0 ^\s*sleep'
        for T in $TABS
            set t (string split ' ' $T)
            set R $t[1]
            set G $t[2]
            set B $t[3]
            set ptn (string join ' ' $t[4..])
            if string length -q -- (string match -r $ptn $argv)
                tab_color $R $G $B
            end
            # printf 'R:%s G:%s B:%s ptn:%s\n' $R $G $B $ptn
        end
    end
    # }}}
end
# }}}

[ -f $HOME/.config/fish/fish.mine ] && source $HOME/.config/fish/fish.mine

