"vim script encoding setting
scriptencoding utf-8

" get vim config directory
function! meflib#basic#get_conf_dir() abort
    if has('nvim')
        let vimdir = stdpath('config')..'/'
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
let s:local_var_def_dict = {}
function! meflib#basic#set_local_var(var_name, val, key='') abort
    if empty(a:key)
        let s:local_var_dict[a:var_name] = a:val
    else
        if !has_key(s:local_var_dict, a:var_name)
            let s:local_var_dict[a:var_name] = {}
        endif
        let s:local_var_dict[a:var_name][a:key] = a:val
    endif
    if has_key(s:local_var_def_dict, a:var_name)
        unlet s:local_var_def_dict[a:var_name]
    endif
endfunction

function! meflib#basic#add_local_var(var_name, var) abort
    if has_key(s:local_var_dict, a:var_name)
        call add(s:local_var_dict[a:var_name], a:var)
    else
        let s:local_var_dict[a:var_name] = [a:var]
    endif
endfunction

function! s:show_vars(var_dict) abort
    for vname in sort(keys(a:var_dict))
        let var = a:var_dict[vname]
        echohl Identifier
        echo vname..': '
        echohl None
        if type(var) == type({})
            for key in sort(keys(var))
                echohl Title
                echo printf('   %s: ', key)
                echohl None
                echon var[key]
            endfor
        else
            echon var
        endif
    endfor
endfunction

function! meflib#basic#get_local_var(var_name, default, key='') abort
    if empty(a:var_name)
        call s:show_vars(s:local_var_dict)
        echohl Special
        echo 'variables used as default'
        echohl None
        call s:show_vars(s:local_var_def_dict)
    elseif has_key(s:local_var_dict, a:var_name)
        if empty(a:key)
            return s:local_var_dict[a:var_name]
        else
            let local_var = s:local_var_dict[a:var_name]
            if has_key(local_var, a:key)
                return s:local_var_dict[a:var_name][a:key]
            else
                return a:default
            endif
        endif
    else
        if empty(a:key)
            let s:local_var_def_dict[a:var_name] = a:default
        else
            if !has_key(s:local_var_def_dict, a:var_name)
                let s:local_var_def_dict[a:var_name] = {}
            endif
            let s:local_var_def_dict[a:var_name][a:key] = a:default
        endif
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
        if arg[0]=='-' && has_key(a:args_config, arg[1:])
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
    let cwd = fnamemodify(a:cwd, ':p')
    for repo_dir in ['.git', 'svn']
        let top_dir = finddir(repo_dir..'/..', cwd..';')
        if !empty(top_dir)
            return top_dir
        endif
    endfor
    return ''
endfunction

" get command to execute default application in each OS.
function! meflib#basic#get_exe_cmd(...) abort
    if a:0 == 0
        if has('mac')
            let cmd = 'open'
        elseif has('win32') || has('win64')
            " let cmd = 'start'
            " 'start' is not executable(?)
            return 'start'
        elseif has('linux')
            let cmd = 'xdg-open'
        else
            let cmd = ''
        endif
    else
        let cmd = a:1
    endif

    if executable(cmd)
        return cmd
    else
        return ''
    endif
endfunction

function! meflib#basic#get_term_color() abort
     " black, red, green, yellow, blue, magenta, cyan, white,
     " bright black, bright red, bright green, bright yellow, bright blue, bright magenta, bright cyan, bright white
     let colors = {}
     let colors['default'] = [
                 \ '#001419', '#dc312e', '#359901', '#bbb402', '#487bc8', '#a94498', '#329691', '#eee8d5',
                 \ '#002833', '#e12419', '#63d654', '#ebe041', '#0081e8', '#b954d3', '#0dc3cd', '#fdf6e3']
     let colors['simple'] = [
                 \ '#000000', '#870000', '#008700', '#878700', '#000087', '#870087', '#008787', '#b2b2b2',
                 \ '#4c4c4c', '#ff0000', '#00ff00', '#ffff00', '#0000ff', '#ff00ff', '#00ffff', '#ffffff']

     let col_name = meflib#get('term_col_name', 'default')
     if match(keys(colors), col_name) == -1
         let col_name = 'default'
     endif
     return colors[col_name]
endfunction

