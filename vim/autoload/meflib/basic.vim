"vim script encording setting
scriptencoding utf-8

" get vim config directory
function! meflib#basic#get_conf_dir() abort
    if has('nvim')
        if exists("$XDG_CONFIG_HOME")
            let vimdir = expand($XDG_CONFIG_HOME . "/nvim/")
        else
            let vimdir = expand('~/.config/nvim/')
        endif
    else
        if has('win32') || has('win64')
            let vimdir = expand('~/vimfiles/')
        else
            let vimdir = expand('~/.vim/')
        endif
    endif

    return vimdir
endfunction

let s:local_var_dict = {}
function! meflib#basic#set_local_var(var_name, val, ...) abort
    " 3つめにindex / key nameが指定されたらvar_nameの[index / key]に値を設定
    if a:0 == 0
        let s:local_var_dict[a:var_name] = a:val
    else
        if !has_key(s:local_var_dict, a:var_name)
            let s:local_var_dict[a:var_name] = {}
        endif
        for i in range(a:0)
            let s:local_var_dict[a:var_name][a:1[i]] = a:val[i]
        endfor
    endif
endfunction

function! meflib#basic#get_local_var(var_name, default) abort
    if empty(a:var_name)
        for var in sort(keys(s:local_var_dict))
            echohl Identifier
            echo var..': '
            echohl None
            echon s:local_var_dict[var]
        endfor
    elseif has_key(s:local_var_dict, a:var_name)
        return s:local_var_dict[a:var_name]
    else
        " let s:local_var_dict[a:var_name] = a:default
        return a:default
    endif
endfunction

" 関数の引数解析用関数 (key=arg)
function! meflib#basic#analythis_args_eq(arg) abort
    let args = split(a:arg, ' ')
    let ret = {'no_key':""}
    let last_key = -1
    for dic in args
        let dic_sub = split(dic, "=", 1)
        if len(dic_sub) < 2
            if last_key != -1
                let ret[last_key] .= ' ' . dic_sub[0]
                if dic_sub[0][-1:] != '\'
                    let last_key = -1
                endif
            else
                let ret["no_key"] .= ' ' . dic_sub[0]
            endif
        else
            let dic_key = dic_sub[0]
            let dic_val = join(dic_sub[1:], '=')
            let ret[dic_key] = dic_val
            if dic_val[-1:] == '\'
                let last_key = dic_key
            endif
        endif
    endfor

    return ret
endfunction

" 関数の引数解析用関数 (-opt arg)
function! meflib#basic#analythis_args_hyp(args, args_config) abort
    let args = split(a:args, ' ')
    let res = {'no_opt':[]}
    let skip_cnt = -1
    " echo args
    for i in range(len(args))
        let arg = args[i]
        " echo '<>'.i.':'.arg
        let opt_num = 0
        if arg[0]=='-'
            let opt = arg[1:]
            let res[opt] = []
            " echo ' set '.opt
            if has_key(a:args_config, opt)
                let opt_num = a:args_config[opt]
            endif
            let skip_cnt = i
            for j in range(i+1, i+opt_num)
                let res[opt] += [args[j]]
                let skip_cnt += 1
                " echo '  '.j.': add '.args[j].'(skip:'.skip_cnt.')'
            endfor
        elseif i <= skip_cnt
            " already set to res dictionary
            " echo 'skip '.i
            continue
        else
            " echo 'no key: '.i.' '.arg
            let res['no_opt'] += [arg]
        endif
        " let test=input('>> ')
    endfor

    return res
endfunction

" search top directory of this project
function! meflib#basic#get_top_dir(cwd) abort
    for repo_dir in ['.git', 'svn']
        let top_dir = finddir(repo_dir..'/..', a:cwd..';')
        if !empty(top_dir)
            return top_dir
        endif
    endfor
    return ''
endfunction

