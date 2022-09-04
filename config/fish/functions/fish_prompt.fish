function _root_prompt
    printf '%s@%s %s%s%s# ' $USER (prompt_hostname) (set -q fish_color_cwd_root
                                                     and set_color $fish_color_cwd_root
                                                     or set_color $fish_color_cwd) \
        (prompt_pwd) (set_color normal)
end

function _prompt_fish
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
end

function _prompt_time
    printf '%s%s%s ' (set_color brgreen) (date "+%H:%M") (set_color normal)
end

function _prompt_user
    printf '%s%s%s ' (set_color red) $USER (set_color normal)
end

function _prompt_pwd
    printf '%s%s%s ' (set_color -b 004090) $PWD (set_color normal)
end

function _prompt_end
    printf '> '
end

function _prompt_host
    if [ -n "$SSH_CLIENT" ]
        printf '%s%s%s ' (set_color cyan) (prompt_hostname) (set_color normal)
    else
        printf ''
    end
end

function _prompt_cnt_file
    printf '(%s)' (ls -U1 | wc -l | sed -e "s/ //g")
end

function _prompt_jobs
    if string length -q -- (jobs)
        printf '%s(J:%s)%s ' (set_color -b magenta) (jobs|wc -l|sed -e "s/ //g") (set_color normal)
    end
end


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
        printf '%s ' $pipestatus_string
        printf '\n'
        _prompt_time
        _prompt_user
        _prompt_jobs
        _prompt_end
    end
end

function fish_right_prompt
    printf '%s ' (__fish_git_prompt)
end
