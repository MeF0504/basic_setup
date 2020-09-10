# set prompt
#
autoload colors
colors

function ip_color() {
    # {{{
    if [[ $1 = '' ]]; then
        local to=1
    else
        local to=$1
    fi

    local ip="$(curl --max-time $to ifconfig.io 2> /dev/null)"
    if [[ $(echo $ip | wc -l) -ne 1 ]]; then
        local ret=""
        ret=$ret"%F{15}%K{16}m%f%k"
        ret=$ret"%F{15}%K{16}i%f%k"
        ret=$ret"%F{15}%K{16}s%f%k"
        ret=$ret"%F{15}%K{16}s%f%k"
        ret=$ret" "
        echo $ret
        return 0
    fi
    if [[ $ip == *.* ]]; then   # IPv4
        ip11=$(echo $ip | cut -f 1 -d ".")
        ip12=$ip11
        ip21=$(echo $ip | cut -f 2 -d ".")
        ip22=$ip21
        ip31=$(echo $ip | cut -f 3 -d ".")
        ip32=$ip31
        ip41=$(echo $ip | cut -f 4 -d ".")
        ip42=$ip41
        ipv=4
    elif [[ $ip == *:* ]]; then     # IPv6
        ip11=$(( 0x$(echo $ip | cut -f 1 -d ":") >> 8))
        ip12=$(( 0x$(echo $ip | cut -f 1 -d ":") & 0xFF))
        ip21=$(( 0x$(echo $ip | cut -f 2 -d ":") >> 8))
        ip22=$(( 0x$(echo $ip | cut -f 2 -d ":") & 0xFF))
        ip31=$(( 0x$(echo $ip | cut -f 3 -d ":") >> 8))
        ip32=$(( 0x$(echo $ip | cut -f 3 -d ":") & 0xFF))
        ip41=$(( 0x$(echo $ip | cut -f 4 -d ":") >> 8))
        ip42=$(( 0x$(echo $ip | cut -f 4 -d ":") & 0xFF))
        ipv=6
    else
        ip11=16 # black
        ip12=16 # black
        ip21=16 # black
        ip22=16 # black
        ip31=16 # black
        ip32=16 # black
        ip41=16 # black
        ip42=16 # black
        ipv="-"
    fi

    ### display colorfully: https://qiita.com/butaosuinu/items/770a040bc9cfe22c71f4
    local ret=""
    ret=$ret"%F{$ip11}%K{$ip12}I%f%k"
    ret=$ret"%F{$ip21}%K{$ip22}P%f%k"
    ret=$ret"%F{$ip31}%K{$ip32}v%f%k"
    ret=$ret"%F{$ip41}%K{$ip42}${ipv}%f%k"
    ret=$ret" "
    echo $ret
    # }}}
}

function ip_color2() {
    # {{{
    # only for IPv6
    if [[ $1 = '' ]]; then
        local to=1
    else
        local to=$1
    fi

    local ip="$(curl --max-time $to ifconfig.io 2> /dev/null)"
    if [[ $(echo $ip | wc -l) -ne 1 ]]; then
        return 0
    fi
    if [[ $ip == *:* ]]; then
        ip11=$(( 0x$(echo $ip | cut -f 5 -d ":") >> 8))
        ip12=$(( 0x$(echo $ip | cut -f 5 -d ":") & 0xFF))
        ip21=$(( 0x$(echo $ip | cut -f 6 -d ":") >> 8))
        ip22=$(( 0x$(echo $ip | cut -f 6 -d ":") & 0xFF))
        ip31=$(( 0x$(echo $ip | cut -f 7 -d ":") >> 8))
        ip32=$(( 0x$(echo $ip | cut -f 7 -d ":") & 0xFF))
        ip41=$(( 0x$(echo $ip | cut -f 8 -d ":") >> 8))
        ip42=$(( 0x$(echo $ip | cut -f 8 -d ":") & 0xFF))
        local ret=""
        ret=$ret"%F{$ip11}%K{$ip12}c%f%k"
        ret=$ret"%F{$ip21}%K{$ip22}o%f%k"
        ret=$ret"%F{$ip31}%K{$ip32}n%f%k"
        ret=$ret"%F{$ip41}%K{$ip42}n%f%k"
        ret=$ret" "
        echo $ret
    fi
    # }}}
}

# OLD_PROMPT=1
case ${UID} in
0)
    PROMPT="%{${fg[yellow]}%}ROOT@%{${fg[cyan]}%}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]') %B%{${fg[red]}%}%/#%{${reset_color}%}%b "
    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
    SPROMPT="%B%{${fg[yellow]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
    ;;
*)
    if [[ -n $OLD_PROMPT ]]; then
        # {{{
        local short="%{${fg[red]}%}%/ S%{${reset_color}%} "
        local long="%{${fg[red]}%}%(4/,%-1/.../%2/,%/) L%{${reset_color}%} "
        PROMPT="%4(/|$long|$short)"
        ## from http://0xcc.net/blog/archives/000032.html
        if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
            PROMPT="%{${fg[cyan]}%}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]') ${PROMPT}"
            #PROMPT="%F{cyan}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]')%f ${PROMPT}"
        else
            PROMPT="%{${fg[green]}%}%T%{${reset_color}%} ${PROMPT}"
        fi
        # }}}
    else
        # path
        PROMPT="%{${bg[cyan]}%}%d%{${reset_color}%}"$'\n'
        # ip_color for IPv6
        PROMPT=$PROMPT'$(ip_color2 $CURLTIMEOUT)'
        if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
            # host name in ssh server
            PROMPT="%{${fg[cyan]}%}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]')%{${reset_color}%} "$PROMPT
        fi
        # time
        PROMPT=$PROMPT"%{${fg[green]}%}%T%{${reset_color}%}"
        # user name (bold)
        PROMPT=$PROMPT" %{${fg[red]}%}%B%n%b%{${reset_color}%}"
        # change red if the previous command was failed.
        # https://blog.8-p.info/2009/01/red-prompt
        PROMPT=$PROMPT"%(?. >> . %{${fg[red]}%}!!%{${reset_color}%} "
    fi
    # ip_color
    if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
        PROMPT="$(ip_color $CURLTIMEOUT)"$PROMPT
    else
        PROMPT='$(ip_color $CURLTIMEOUT)'$PROMPT
    fi

    PROMPT2="%{${fg[red]}%}%_%%%{${reset_color}%} "
    SPROMPT="%{${fg[yellow]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    ;;
esac

# show git status in right prompt
#
# http://tkengo.github.io/blog/2013/05/12/zsh-vcs-info/
# or http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' max-exports 6 # formatに入る変数の最大数
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr " %{${fg[yellow]}%}cmt%{${reset_color}%}"
zstyle ':vcs_info:git:*' unstagedstr " %{${fg[red]}%}add%{${reset_color}%}"
zstyle ':vcs_info:git:*' formats "%{${fg[green]}%}GIT [%b]%{${reset_color}%}%c%u"
zstyle ':vcs_info:git:*' actionformats '! %a %c %u'
setopt prompt_subst

function rprom() {
    vcs_info
    RPROMPT="${vcs_info_msg_0_}"
    #echo $RPROMPT
}
add-zsh-hook precmd rprom


