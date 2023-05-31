"vim script encoding setting
scriptencoding utf-8

" get vim config directory {{{
" <sfile> は関数外で呼ぶ
let s:vimdir = expand('<sfile>:h:h:h')..'/'
function! meflib#basic#get_conf_dir() abort
    if has('nvim')
        let vimdir = stdpath('config')..'/'
    else
        let vimdir = s:vimdir
    endif

    return vimdir
endfunction
" }}}
" set, get, add {{{
let s:local_var_dict = {}
let s:local_var_def_dict = {}
function! meflib#basic#set_local_var(var_name, args1, args2=v:null) abort
    if type(a:args2) == type(v:null)
        " args1 = val
        let s:local_var_dict[a:var_name] = a:args1
    else
        " args1 = key, args2 = val
        if !has_key(s:local_var_dict, a:var_name)
            let s:local_var_dict[a:var_name] = {}
        endif
        let s:local_var_dict[a:var_name][a:args1] = a:args2
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
    if has_key(s:local_var_def_dict, a:var_name)
        unlet s:local_var_def_dict[a:var_name]
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

function! meflib#basic#get_local_var(var_name, args1, args2=v:null) abort
    if empty(a:var_name)
        call s:show_vars(s:local_var_dict)
        echohl Special
        echo 'variables used as default'
        echohl None
        call s:show_vars(s:local_var_def_dict)
    elseif has_key(s:local_var_dict, a:var_name)
        if type(a:args2) == type(v:null)
            return s:local_var_dict[a:var_name]
        else
            " args1 = key, args2 = default
            let local_var = s:local_var_dict[a:var_name]
            if has_key(local_var, a:args1)
                return s:local_var_dict[a:var_name][a:args1]
            else
                return a:args2
            endif
        endif
    else
        if type(a:args2) == type(v:null)
            let default = a:args1
            let s:local_var_def_dict[a:var_name] = default
        else
            let key = a:args1
            let default = a:args2
            if !has_key(s:local_var_def_dict, a:var_name)
                let s:local_var_def_dict[a:var_name] = {}
            endif
            let s:local_var_def_dict[a:var_name][key] = default
        endif
        return default
    endif
endfunction
" }}}
" 関数の引数解析用関数 (key=arg) {{{
function! meflib#basic#analythis_args_eq(arg) abort
    let args = split(a:arg, ' ')
    let ret = {'no_key':""}
    let last_key = 'no_key'
    for dic in args
        let dic_sub = split(dic, "=", 1)
        if len(dic_sub) < 2
            " no equal
            let ret[last_key] .= ' ' . dic_sub[0]
        else
            let dic_key = dic_sub[0]
            let dic_val = join(dic_sub[1:], '=')
            let ret[dic_key] = dic_val
            " update key
            let last_key = dic_key
        endif
    endfor

    return ret
endfunction
" }}}
" 関数の引数解析用関数 (-opt arg) {{{
function! meflib#basic#analythis_args_hyp(args, args_config) abort
    let args = split(a:args, ' ')
    let res = {'no_opt':[]}
    let i = 0
    while i < len(args)
        let arg = args[i]
        if arg[0] ==# '-' && has_key(a:args_config, arg[1:])
            let opt = arg[1:]
            let opt_num = a:args_config[opt]
            let res[opt] = args[i+1:i+opt_num]
            if len(res[opt]) != opt_num
                echohl ErrorMsg
                echo "incorrect arguments"
                echohl None
                return {}
            endif
            let i += opt_num
        else
            call add(res['no_opt'], arg)
        endif
        let i += 1
    endwhile
    return res
endfunction
" }}}
" search top directory of this project {{{
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
" }}}
" get command to execute default application in each OS. {{{
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
" }}}
" get term color for {{{
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
" }}}
" get highlight setting {{{
function! meflib#basic#get_hi_info(group_name, keys) abort
    let hi = execute(printf('highlight %s', a:group_name))->split(' ')
    if type(a:keys) == type([])
        let keys = a:keys
    else
        let keys = [a:keys]
    endif
    let res = []
    for key in keys
        let idx = match(hi, key)
        if idx == -1
            call add(res, 'NONE')
        else
            call add(res, hi[idx][len(key)+1:])
        endif
    endfor
    return res
endfunction
" }}}
" scratch buffer {{{
function! meflib#basic#set_scratch(text) abort
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nolist
    setlocal nowrap
    setlocal modifiable
    silent %delete _
    call append(0, a:text)
    setlocal nomodifiable
endfunction
" }}}
" 特殊window判断 {{{
function! meflib#basic#special_win(winid)
    return
            \ getwinvar(a:winid, '&previewwindow')
            \ || (getwinvar(a:winid, '&buftype')=='nofile')
            \ || (getwinvar(a:winid, '&filetype')=='qf')
            \ || (getwinvar(a:winid, '&buftype')=='help')
endfunction
" }}}
" terminal buffer 一覧 {{{
function! meflib#basic#term_list() abort
    if exists('*term_list')
        let term_list = term_list()
    else
        if has('nvim')
            let st_idx = 6
            let term_head = 'term://'
        else
            let st_idx = 0
            let term_head = '!'
        endif
        let term_list = []
        for i in range(1, bufnr('$'))
            let bname = bufname(i)
            if bname[:st_idx] == term_head
                let term_list += [i]
            endif
        endfor
    endif
    return term_list
endfunction
" }}}
