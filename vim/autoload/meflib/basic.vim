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
let s:local_var_setlog = {}
function! meflib#basic#set_local_var(var_name, args1, args2=v:null) abort
    call meflib#debug#debug_log(printf('set %s @ %s', a:var_name, expand('<sfile>')), 'meflib-set')
    let s:local_var_setlog[a:var_name] = expand('<sfile>')
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
    call meflib#debug#debug_log(printf('add %s', a:var_name), 'meflib-add')
    let s:local_var_setlog[a:var_name] = expand('<sfile>')
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
        echo 'input variable name is empty.'
        return
    elseif has_key(s:local_var_dict, a:var_name)
        if type(a:args2) == type(v:null)
            return s:local_var_dict[a:var_name]
        else
            " args1 = key, args2 = default
            let local_var = s:local_var_dict[a:var_name]
            if has_key(local_var, a:args1)
                return s:local_var_dict[a:var_name][a:args1]
            else
                call meflib#debug#debug_log(printf('get def %s, %s', a:var_name, a:args1),
                            \ 'meflib-get')
                return a:args2
            endif
        endif
    else
        if !has_key(s:local_var_def_dict, a:var_name)
            call meflib#debug#debug_log(printf('get def %s', a:var_name), 'meflib-get')
        endif
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

function! meflib#basic#var_comp(arglead, cmdline, cursorpos) abort
    let comp_list = keys(s:local_var_dict)+keys(s:local_var_def_dict)
    return filter(comp_list, '!stridx(v:val, a:arglead)')
endfunction

function! meflib#basic#show_var(bang, var_name='') abort
    let var_pat = printf("^%s$", a:var_name)
    if empty(a:var_name)
        call s:show_vars(s:local_var_dict)
        echohl Special
        echo 'variables used as default'
        echohl None
        call s:show_vars(s:local_var_def_dict)
        return
    elseif match(keys(s:local_var_dict)+keys(s:local_var_def_dict), var_pat) == -1
        echo "no such key."
        return
    else
        if match(keys(s:local_var_dict), var_pat) != -1
            let tmp = s:local_var_dict[a:var_name]
            if type(tmp) == type({})
                for key in sort(keys(tmp))
                    echohl Title
                    echo printf('%s: ', key)
                    echohl None
                    echon tmp[key]
                endfor
            else
                echo tmp
            endif
            if !empty(a:bang)
                let set_log = s:local_var_setlog[a:var_name]
            else
                let set_log = split(s:local_var_setlog[a:var_name], '\.\.')
                let set_log = set_log[len(set_log)-3]
            endif
            echo ' >> LAST SET: '..set_log
        elseif match(keys(s:local_var_def_dict), var_pat) != -1
            echohl Special
            echo "default"
            echohl None
            let tmp = s:local_var_def_dict[a:var_name]
            if type(tmp) == type({})
                for key in sort(keys(tmp))
                    echohl Title
                    echo printf('%s: ', key)
                    echohl None
                    echon tmp[key]
                endfor
            else
                echo tmp
            endif
        endif
    endif
endfunction
" }}}
" 関数の引数解析用関数 (-opt arg) {{{
function! meflib#basic#analythis_args_hyp(args, args_config) abort
    let args = split(a:args, ' ')
    let res = {'no_opt':[]}
    let opt_max = 0
    for i in range(len(args))
        let arg = args[i]
        if arg[0] ==# '-' && has_key(a:args_config, arg[1:])
            let opt = arg[1:]
            let opt_num = a:args_config[opt]
            let res[opt] = []
            if opt_num ==# '*'
                let opt_max = len(args)
            else
                let opt_max = i+1+opt_num
            endif
        elseif i < opt_max
            call add(res[opt], arg)
        else
            call add(res['no_opt'], arg)
        endif
    endfor
    for k in keys(res)
        if k ==# 'no_opt'
            continue
        endif
        if a:args_config[k] ==# '*'
            continue
        endif
        if len(res[k]) != a:args_config[k]
            echohl ErrorMsg
            echo "incorrect arguments: " .. k
            echohl None
            return {}
        endif
    endfor
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
 " multi-mapping(?)用 {{{
 function! meflib#basic#map_util(name) abort
    let map_cmds = meflib#get('map_cmds', {})
    if empty(map_cmds)
        echo 'no maps registered.'
        return
    endif
    if !has_key(map_cmds, a:name)
        echo printf('incorrect map name: "%s"', a:name)
        return
    endif
    let cmds = map_cmds[a:name]
    if empty(cmds)
        echo printf('no maps in "%s".', a:name)
        return
    endif

    if len(cmds) == 1
        let cmd = values(cmds)[0]
        execute cmd
        return
    endif

    let old_cmdheight = &cmdheight
    let &cmdheight = len(cmds)+1
    echo map(deepcopy(cmds),
                \ {key, val -> key..': '..val})->values()->join("\n").."\n"
    " let key = input('key: ')
    let key = getcharstr()
    let &cmdheight = old_cmdheight
    normal! :
    if has_key(cmds, key)
        execute cmds[key]
    endif
endfunction
" }}}
