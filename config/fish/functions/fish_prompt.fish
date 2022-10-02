function _root_prompt
    printf '%s@%s %s%s%s # ' $USER (prompt_hostname) \
        (set -q fish_color_cwd_root
        and set_color $fish_color_cwd_root
        or set_color $fish_color_cwd) \
        (prompt_pwd) (set_color normal)
end

function _prompt_fish
    printf '%s%s' (set_color -b 002060) (set_color white)
    switch (echo (random) % 6 | bc)
        case 0
            printf '%s-%s ' \U1f41f $SHLVL
        case 1
            printf '%s-%s ' \U1f420 $SHLVL
        case 2
            printf '%s-%s ' \U1f421 $SHLVL
        case 3
            printf '%s-%s ' \U1f42c $SHLVL
        case 4
            printf '%s-%s ' \U1f433 $SHLVL
        case 5
            printf '%s-%s ' \U1f988 $SHLVL
    end
    printf '%s%s%s%s' (set_color -b normal) (set_color 002060) \Ue0c6 (set_color normal)
end

function _prompt_time
    printf '%s%s%s%s' \
    (set_color -b brgreen) (set_color black) \
    (date "+%H:%M") (set_color normal)
end

function _prompt_user
    printf '%s%s%s%s%s%s%s' \
    (set_color brgreen) (set_color -b red) \Ue0b0 \
    (set_color -b red) (set_color black) $USER \
    (set_color normal)
end

function _prompt_pwd
    printf '%s%s%s%s%s%s%s%s%s' (set_color -b normal) (set_color 006090) \Ue0c7 \
    (set_color -b 006090) (set_color white)  $PWD \
    (set_color -b normal) (set_color 006090) \Ue0c8 \
    (set_color normal)
end

function _prompt_end
    printf '%s' (set_color -b normal)
    if string length -q -- (jobs)
        printf '%s' (set_color magenta)
    else
        printf '%s' (set_color red)
    end
    printf '%s%s ' \Ue0b0 (set_color normal)
end

function _prompt_host
    if [ -n "$SSH_CLIENT" ]
        printf '%s%s%s' (set_color cyan) (prompt_hostname) (set_color normal)
    else
        printf ''
    end
end

function _prompt_cnt_file
    printf '(%s)' (ls -U1 | wc -l | sed -e "s/ //g")
end

function _prompt_jobs
    if string length -q -- (jobs)
        printf '%s%s%s%s%s(J:%s)%s' \
        (set_color red) (set_color -b magenta) \Ue0b0 \
        (set_color -b magenta) (set_color white) \
        (jobs|wc -l|sed -e "s/ //g") \
        (set_color normal)
    end
end

# calculate execute time {{{
set -g _prompt_show_time 10
function _prompt_cnt_time_pre --on-event fish_preexec
    set -g __pre_time (date '+%s')
end

function _prompt_cnt_time_post --on-event fish_postexec
    if [ -n "$__pre_time" ]
        set post_time (date '+%s')
        set -g __exec_time (math $post_time - $__pre_time)
    end
end

function _prompt_cnt_time
    set res ''
    if [ -n "$__exec_time" ]
        if [ $__exec_time -gt $_prompt_show_time ]
            set d (math --scale 0 $__exec_time / 60 / 60 / 24)
            set h (math --scale 0 $__exec_time / 60 / 60  % 24)
            set m (math --scale 0 $__exec_time / 60  % 60)
            set s (math --scale 0 $__exec_time % 60)
            [ $d -gt 1 ]; and set res $res$d'd '
            [ $h -gt 1 ]; and set res $res$h'h '
            [ $m -gt 1 ]; and set res $res$m'm '
            [ $s -gt 1 ]; and set res $res$s's '
        end
    end
    set --erase -g __pre_time
    set --erase -g __exec_time
    printf ' %s' $res
end
# }}}

function _prompt_image
    if [ (which imgcat) ]
        set -l main_gif "$HOME/.config/fish/prompt/main.gif"
        set -l git_gif "$HOME/.config/fish/prompt/git.gif"
        if string length -q -- (__fish_git_prompt)
            and [ -f $git_gif ]
            imgcat $git_gif
        else if [ -f $main_gif ]
            imgcat $main_gif
        else
            printf '\n'
        end
    else
        printf '\n'
    end
end


# require Nerd Font.
function fish_prompt --description 'Informative prompt'
    #Save the return status of the previous command
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.

    if functions -q fish_is_root_user; and fish_is_root_user
        _root_prompt
    else
        set -l status_color (set_color $fish_color_status)
        set -l statusb_color (set_color --bold $fish_color_status)
        set -l pipestatus_string (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

        _prompt_fish
        _prompt_host
        _prompt_pwd
        _prompt_cnt_file
        _prompt_cnt_time
        printf '%s ' $pipestatus_string
        _prompt_image
        # printf '\n' # imgcatで改行されるので...
        _prompt_time
        _prompt_user
        _prompt_jobs
        _prompt_end
    end
end

function fish_right_prompt
    printf '%s ' (__fish_git_prompt)
end
