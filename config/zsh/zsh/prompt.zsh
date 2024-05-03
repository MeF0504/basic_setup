# set prompt

export PROMPTTO=1   # default value
# functions of ip address and ip-color {{{

function get_ip()
{
    local to=${1:-$PROMPTTO}
    local get_ip_server=${IPSERVER:-"ifconfig.io"}
    # ifconfig.io, icanhazip.com, inet-ip.info, ipconfig.me, etc.
    if [[ $to -ne -1 ]]; then
        if [[ "$(which timeout &> /dev/null; echo $?)" -eq 0 ]]; then
            # echo "1-${to}" >&2
            local ip="$( timeout "$to" curl $get_ip_server 2> /dev/null)"
        elif [[ "$(which timeout_local &> /dev/null; echo $?)" -eq 0 ]]; then
            # echo "2-${to}" >&2
            local ip="$( timeout_local "$to" 'curl ifconfig.io 2> /dev/null')"
        else
            # echo "3-${to}" >&2
            local ip="$(curl --max-time "$to" ifconfig.io 2> /dev/null)"
        fi
        export _GLOBAL_IP=$ip
    fi
    # echo "$ip"
}
# do get_ip 1 time per 1 min.
if [ -z "${SSH_CLIENT}${SSH_CONNECTION}" ]; then
    export PERIOD=60
    add-zsh-hook periodic get_ip
fi

function ip_color()
{
    # {{{
    local ip=$1
    if [[ $(echo "$ip" | wc -l) -ne 1 ]]; then
        local ret=""
        ret=$ret"%F{15}%K{16}m%f%k"
        ret=$ret"%F{15}%K{16}i%f%k"
        ret=$ret"%F{15}%K{16}s%f%k"
        ret=$ret"%F{15}%K{16}s%f%k"
        ret=$ret" "
        echo "$ret"
        return 0
    fi

    # display colorfully:
    # https://qiita.com/butaosuinu/items/770a040bc9cfe22c71f4
    # https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
    if [[ $ip == *.* ]]; then   # IPv4
        eval "ipnum=(${ip//./ })"
        ip1f=15
        ip1b=${ipnum[1]}
        ip2f=15
        ip2b=${ipnum[2]}
        ip3f=15
        ip3b=${ipnum[3]}
        ip4f=15
        ip4b=${ipnum[4]}
        ip1="%F{$ip1f}%K{$ip1b}"
        ip2="%F{$ip2f}%K{$ip2b}"
        ip3="%F{$ip3f}%K{$ip3b}"
        ip4="%F{$ip4f}%K{$ip4b}"
    elif [[ $ip == *:* ]]; then     # IPv6
        eval "ipnum=(${ip//:/ })"
        ip1f=$(( 0x${ipnum[1]} >> 8 ))
        ip1r=$(( 0x${ipnum[1]} & 0xFF ))
        ip1g=$(( 0x${ipnum[2]} >> 8 ))
        ip1b=$(( 0x${ipnum[2]} & 0xFF ))
        ip2f=$(( 0x${ipnum[3]} >> 8 ))
        ip2r=$(( 0x${ipnum[3]} & 0xFF ))
        ip2g=$(( 0x${ipnum[4]} >> 8 ))
        ip2b=$(( 0x${ipnum[4]} & 0xFF ))
        ip3f=$(( 0x${ipnum[5]} >> 8 ))
        ip3r=$(( 0x${ipnum[5]} & 0xFF ))
        ip3g=$(( 0x${ipnum[6]} >> 8 ))
        ip3b=$(( 0x${ipnum[6]} & 0xFF ))
        ip4f=$(( 0x${ipnum[7]} >> 8 ))
        ip4r=$(( 0x${ipnum[7]} & 0xFF ))
        ipnum8=$(echo "${ipnum[8]}" | sed -e  "s///g")
        ip4g=$(( 0x${ipnum8} >> 8 ))
        ip4b=$(( 0x${ipnum8} & 0xFF ))
        ip1="%F{${ip1f}}\033[48;2;${ip1r};${ip1g};${ip1b}m"
        ip2="%F{${ip2f}}\033[48;2;${ip2r};${ip2g};${ip2b}m"
        ip3="%F{${ip3f}}\033[48;2;${ip3r};${ip3g};${ip3b}m"
        ip4="%F{${ip4f}}\033[48;2;${ip4r};${ip4g};${ip4b}m"
    else
        ip1="%F{15}%K{0}"
        ip2="%F{15}%K{0}"
        ip3="%F{15}%K{0}"
        ip4="%F{15}%K{0}"
    fi

    local ch0=${SHELL_INFO:0:1}
    local ch1=${SHELL_INFO:1:1}
    local ch2=${SHELL_INFO:2:1}
    local ch3=${SHELL_INFO:3}

    local ret=""
    ret=$ret"${ip1}${ch0}%f%k"
    ret=$ret"${ip2}${ch1}%f%k"
    ret=$ret"${ip3}${ch2}%f%k"
    ret=$ret"${ip4}${ch3}%f%k"
    ret=$ret" "
    echo "$ret"
    # }}}
}
# }}}

# {{{ calculate the command execution time
# from https://github.com/sindresorhus/pure
CMD_MAX_EXEC_TIME=10
chk_exec_time_precmd() {
    chk_exec_time
    unset cmd_timestamp
}
chk_exec_time_preexec() {
    typeset -g cmd_timestamp=$EPOCHSECONDS
}
add-zsh-hook preexec chk_exec_time_preexec
add-zsh-hook precmd chk_exec_time_precmd

# Turns seconds into human readable time.
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
exec_human_time_to_var() {
    local human total_seconds=$1 var=$2
    local days=$(( total_seconds / 60 / 60 / 24 ))
    local hours=$(( total_seconds / 60 / 60 % 24 ))
    local minutes=$(( total_seconds / 60 % 60 ))
    local seconds=$(( total_seconds % 60 ))
    (( days > 0 )) && human+="${days}d "
    (( hours > 0 )) && human+="${hours}h "
    (( minutes > 0 )) && human+="${minutes}m "
    human+="${seconds}s"

    # Store human readable time in a variable as specified by the caller
    typeset -g "${var}"="${human}"
}

chk_exec_time() {
    integer elapsed
    (( elapsed = EPOCHSECONDS - ${cmd_timestamp:-$EPOCHSECONDS} ))
    typeset -g chk_cmd_exec_time=
    (( elapsed > ${CMD_MAX_EXEC_TIME:-5} )) && {
        exec_human_time_to_var $elapsed "chk_cmd_exec_time"
    }
}

ret_cmd_exec_time() {
    echo $chk_cmd_exec_time
}
# }}}

# OLD_PROMPT=1
set_prompt() {
    case ${UID} in
    0)
        # ROOT
        PROMPT="%{${fg[yellow]}%}ROOT@%{${fg[cyan]}%}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]') %B%{${fg[red]}%}%/#%{${reset_color}%}%b "
        PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
        SPROMPT="%B%{${fg[yellow]}%}%r is correct? [n(o),y(es),a(bort),e(dit)]:%{${reset_color}%}%b "
        ;;
    *)
        if [[ -n "$OLD_PROMPT" ]]; then
            # {{{
            local short="%{${fg[red]}%}%/ S%{${reset_color}%} "
            local long="%{${fg[red]}%}%(4/,%-1/.../%2/,%/) L%{${reset_color}%} "
            PROMPT="%4(/|$long|$short)"
            ## from http://0xcc.net/blog/archives/000032.html
            if [ -n "${SSH_CLIENT}${SSH_CONNECTION}" ]; then
                PROMPT="%{${fg[cyan]}%}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]') ${PROMPT}"
                #PROMPT="%F{cyan}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]')%f ${PROMPT}"
            else
                PROMPT="%{${fg[green]}%}%T%{${reset_color}%} ${PROMPT}"
            fi
            # }}}
        else
            get_ip 3
            # path
            local _PS_PATH="%F{255}%K{19}%d%f%k"
            # count files/directories
            local _PS_COUNTFILE='($(ls -U1 | wc -l | sed -e "s/ //g"))'
            # exec time
            local _PS_EXTIME=' $(ret_cmd_exec_time)'
            # new line
            local _PS_NEWLINE=$'\n'
            if [ -n "${SSH_CLIENT}${SSH_CONNECTION}" ]; then
                # host name in ssh server
                local _PS_HOST="%F{14}$(echo ${MYHOST} | tr '[a-z]' '[A-Z]')%f%k "
            fi
            # time
            local _PS_TIME="%F{42}%D{%H:%M}%f%k"
            # user name (bold username non-bold)
            local _PS_USER=" %F{160}%B%n%b%f%k"
            # background job number (shown if num>=1)
            # also refer ↓
            # https://stackoverflow.com/questions/10194094/zsh-prompt-checking-if-there-are-any-background-jobs
            local _PS_BGJOB="%(1j. %K{5}(J:%j)%f%k.)"
            # change the color to magenta if the previous command was failed.
            # https://blog.8-p.info/2009/01/red-prompt
            local _PS_END=" %(?.>>.%F{125}>>%f%k) "
        fi
        # ip_color
        local _PS_IPCOLOR='$(ip_color $_GLOBAL_IP)'

        export PROMPT="${_PS_IPCOLOR}${_PS_HOST}${_PS_PATH}${_PS_COUNTFILE}${_PS_EXTIME}${_PS_NEWLINE}${_PS_TIME}${_PS_USER}${_PS_BGJOB}${_PS_END}"

        PROMPT2="%{${fg[red]}%}%_%%%{${reset_color}%} "

        SPROMPT="%B%{${fg[yellow]}%}%r is correct? [n(o),y(es),a(bort),e(dit)]:%{${reset_color}%}%b "
        # ↑ %R は修正前のコマンドらしい
        ;;
    esac
}
set_prompt
# PROMPTが表示されるたびにPROMPT分を再評価する
setopt prompt_subst

RPROMPT=''

function _set_per()
{
    export _PERCENTAGE_TODAY="$(today_percentage 2> /dev/null)%%"
}
add-zsh-hook periodic _set_per
_PERCENTAGE_TODAY="$(today_percentage 2> /dev/null)%%"

function set_rprompt()
{
    local git_status="$(_update_vcs_info_msg)"
    if [[ -z "$git_status" ]]; then
        RPROMPT=$_PERCENTAGE_TODAY
    else
        RPROMPT="$git_status"
    fi
}

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

        if [[ "${hook_com[branch]}" != "master" ]] && \
           [[ "${hook_com[branch]}" != "main" ]]; then
            # master, main ブランチでない場合は何もしない
            return 0
        else
            BRA=${hook_com[branch]}
        fi

        # push していないコミット数を取得する
        local ahead
        ahead=$(command git rev-list origin/$BRA..$BRA 2>/dev/null \
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

        if [[ "${hook_com[branch]}" = "master" ]] || \
           [[ "${hook_com[branch]}" = "main" ]]; then
            # master, main ブランチの場合は何もしない
            return 0
        else
            if [[ "$(git branch)" =~ "master" ]]; then
                BRA="master"
            elif [[ "$(git branch)" =~ "master" ]]; then
                BRA="main"
            else
                # ?
                BRA="main"
            fi
        fi

        local nomerged
        nomerged=$(command git rev-list $BRA..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')

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

function _update_vcs_info_msg()
{
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

    echo "$prompt"
}
add-zsh-hook precmd set_rprompt

