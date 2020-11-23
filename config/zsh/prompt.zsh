# set prompt

function ip_color() {
    # {{{
    if [ -n "$CURLTIMEOUT" ]; then
        local to=$CURLTIMEOUT
    else
        if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
            # wait long time in ssh server since it works only once.
            local to=3
        else
            local to=1
        fi
    fi

    if [ -n "$1" ]; then
        local ip=$1
    else
        local ip="$(curl --max-time $to ifconfig.io 2> /dev/null)"
    fi
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
    if [ -n "$CURLTIMEOUT" ]; then
        local to=$CURLTIMEOUT
    else
        if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
            # wait long time in ssh server since it works only once.
            local to=3
        else
            local to=1
        fi
    fi

    if [ -n "$1" ]; then
        local ip=$1
    else
        local ip="$(curl --max-time $to ifconfig.io 2> /dev/null)"
    fi
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
set_prompt() {
    case ${UID} in
    0)
        PROMPT="%{${fg[yellow]}%}ROOT@%{${fg[cyan]}%}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]') %B%{${fg[red]}%}%/#%{${reset_color}%}%b "
        PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
        SPROMPT="%B%{${fg[yellow]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
        ;;
    *)
        if [[ -n "$OLD_PROMPT" ]]; then
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
            # get ip address in ssh server
            if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
                local ip="$(curl ifconfig.io 2> /dev/null)"
            fi
            # path
            PROMPT="%F{255}%K{12}%d%f%k"$'\n'
            # ip_color for IPv6
            PROMPT=$PROMPT'$(ip_color2 $ip)'
            if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
                # host name in ssh server
                PROMPT="%F{14}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]')%f%k "$PROMPT
            fi
            # time
            PROMPT=$PROMPT"%F{42}%D{%H:%M}%f%k"
            # user name (bold)
            PROMPT=$PROMPT" %F{160}%B%n%b%f%k"
            # change the color to magenta if the previous command was failed.
            # https://blog.8-p.info/2009/01/red-prompt
            PROMPT=$PROMPT"%(?. >> . %F{125}>>%f%k "
        fi
        # ip_color
        PROMPT='$(ip_color $ip)'$PROMPT

        PROMPT2="%{${fg[red]}%}%_%%%{${reset_color}%} "

        SPROMPT="%{${fg[yellow]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
        ;;
    esac
}
set_prompt
# PROMPTが表示されるたびにPROMPT分を再評価する
setopt prompt_subst

# show git status in right prompt
# {{{ old settings...
## # http://tkengo.github.io/blog/2013/05/12/zsh-vcs-info/
## # or http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
## autoload -Uz add-zsh-hook
## autoload -Uz vcs_info
## zstyle ':vcs_info:*' enable git svn
## zstyle ':vcs_info:*' max-exports 6 # formatに入る変数の最大数
## zstyle ':vcs_info:git:*' check-for-changes true
## zstyle ':vcs_info:git:*' stagedstr " %{${fg[yellow]}%}cmt%{${reset_color}%}"
## zstyle ':vcs_info:git:*' unstagedstr " %{${fg[red]}%}add%{${reset_color}%}"
## zstyle ':vcs_info:git:*' formats "%{${fg[green]}%}GIT [%b]%{${reset_color}%}%c%u"
## zstyle ':vcs_info:git:*' actionformats '! %a %c %u'
##
## function rprom() {
##     vcs_info
##     RPROMPT="${vcs_info_msg_0_}"
##     #echo $RPROMPT
## }
## add-zsh-hook precmd rprom
# }}}

RPROMPT=''
# https://qiita.com/mollifier/items/8d5a627d773758dd8078
autoload -Uz vcs_info
# 以下の3つのメッセージをエクスポートする
#   $vcs_info_msg_0_ : 通常メッセージ用 (緑)
#   $vcs_info_msg_1_ : 警告メッセージ用 (黄色)
#   $vcs_info_msg_2_ : エラーメッセージ用 (赤)
zstyle ':vcs_info:*' max-exports 3

zstyle ':vcs_info:*' enable git svn hg bzr
# 標準のフォーマット(git 以外で使用)
# misc(%m) は通常は空文字列に置き換えられる
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true


if is-at-least 4.3.10; then
    # git 用のフォーマット
    # git のときはステージしているかどうかを表示
    zstyle ':vcs_info:git:*' formats '(%s)-[%b]' '%c%u %m'
    zstyle ':vcs_info:git:*' actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "+"    # %c で表示する文字列
    zstyle ':vcs_info:git:*' unstagedstr "*"  # %u で表示する文字列
fi

# hooks 設定
if is-at-least 4.3.11; then
    # git のときはフック関数を設定する

    # formats '(%s)-[%b]' '%c%u %m' , actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    # のメッセージを設定する直前のフック関数
    # 今回の設定の場合はformat の時は2つ, actionformats の時は3つメッセージがあるので
    # 各関数が最大3回呼び出される。
    zstyle ':vcs_info:git+set-message:*' hooks \
                                            git-hook-begin \
                                            git-untracked \
                                            git-push-status \
                                            git-nomerge-branch \
                                            git-stash-count

    # フックの最初の関数
    # git の作業コピーのあるディレクトリのみフック関数を呼び出すようにする
    # (.git ディレクトリ内にいるときは呼び出さない)
    # .git ディレクトリ内では git status --porcelain などがエラーになるため
    function +vi-git-hook-begin() {
        if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
            # 0以外を返すとそれ以降のフック関数は呼び出されない
            return 1
        fi

        return 0
    }

    # untracked ファイル表示
    #
    # untracked ファイル(バージョン管理されていないファイル)がある場合は
    # unstaged (%u) に ? を表示
    function +vi-git-untracked() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if command git status --porcelain 2> /dev/null \
            | awk '{print $1}' \
            | command grep -F '??' > /dev/null 2>&1 ; then

            # unstaged (%u) に追加
            hook_com[unstaged]+='?'
        fi
    }

    # push していないコミットの件数表示
    #
    # リモートリポジトリに push していないコミットの件数を
    # pN という形式で misc (%m) に表示する
    function +vi-git-push-status() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if [[ "${hook_com[branch]}" != "master" ]]; then
            # master ブランチでない場合は何もしない
            return 0
        fi

        # push していないコミット数を取得する
        local ahead
        ahead=$(command git rev-list origin/master..master 2>/dev/null \
            | wc -l \
            | tr -d ' ')

        if [[ "$ahead" -gt 0 ]]; then
            # misc (%m) に追加
            hook_com[misc]+="(p${ahead})"
        fi
    }

    # マージしていない件数表示
    #
    # master 以外のブランチにいる場合に、
    # 現在のブランチ上でまだ master にマージしていないコミットの件数を
    # (mN) という形式で misc (%m) に表示
    function +vi-git-nomerge-branch() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if [[ "${hook_com[branch]}" == "master" ]]; then
            # master ブランチの場合は何もしない
            return 0
        fi

        local nomerged
        nomerged=$(command git rev-list master..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')

        if [[ "$nomerged" -gt 0 ]] ; then
            # misc (%m) に追加
            hook_com[misc]+="(m${nomerged})"
        fi
    }


    # stash 件数表示
    #
    # stash している場合は :SN という形式で misc (%m) に表示
    function +vi-git-stash-count() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        local stash
        stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')
        if [[ "${stash}" -gt 0 ]]; then
            # misc (%m) に追加
            hook_com[misc]+=":S${stash}"
        fi
    }

fi

function _update_vcs_info_msg() {
    local -a messages
    local prompt

    LANG=en_US.UTF-8 vcs_info

    if [[ -z ${vcs_info_msg_0_} ]]; then
        # vcs_info で何も取得していない場合はプロンプトを表示しない
        prompt=""
    else
        # vcs_info で情報を取得した場合
        # $vcs_info_msg_0_ , $vcs_info_msg_1_ , $vcs_info_msg_2_ を
        # それぞれ緑、黄色、赤で表示する
        [[ -n "$vcs_info_msg_0_" ]] && messages+=( "%F{green}${vcs_info_msg_0_}%f" )
        [[ -n "$vcs_info_msg_1_" ]] && messages+=( "%F{yellow}${vcs_info_msg_1_}%f" )
        [[ -n "$vcs_info_msg_2_" ]] && messages+=( "%F{red}${vcs_info_msg_2_}%f" )

        # 間にスペースを入れて連結する
        prompt="${(j: :)messages}"
    fi

    RPROMPT="$prompt"
}
add-zsh-hook precmd _update_vcs_info_msg

