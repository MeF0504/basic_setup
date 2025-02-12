scriptencoding utf-8
" vimからfind

let s:args_keys = ['name', 'dir', 'depth']  " keysだと順番が不定なので
let s:args_vals = [1, 1, 1]
let s:args_config = {}
for s:i in range(len(s:args_keys))
    let s:args_config[s:args_keys[s:i]] = s:args_vals[s:i]
endfor
" 補完
function! meflib#find#comp(arglead, cmdline, cursorpos) abort
    let opt_idx = strridx(a:cmdline, '-')
    let end_space_idx = strridx(a:cmdline, ' ')
    if a:arglead[0] == '-'
        let not_entered_list = filter(map(copy(s:args_keys), '"-"..v:val'),
                    \ 'stridx(tolower(a:cmdline), tolower(v:val)) == -1')
        return filter(not_entered_list, '!stridx(tolower(v:val), a:arglead)')
    elseif a:cmdline[opt_idx:end_space_idx-1] == '-dir'
        return getcompletion(a:arglead, "dir")
    else
        return []
    endif
endfunction

function! s:find_cb(files, wid, res) abort
    if a:res > 0
        execute "tabnew "..a:files[a:res-1]
    endif
endfunction

function! meflib#find#main(args) abort
    let def_dir = '.'
    if meflib#get('get_top_dir', 0) == 1
        let top_dir = meflib#basic#get_top_dir(expand('%:h'))
        if !empty(top_dir)
            let def_dir = top_dir
        endif
    endif
    let arg = meflib#basic#analythis_args_hyp(a:args, s:args_config)
    if !has_key(arg, 'name')
        echoerr "file name is not specified."
        return
    endif
    if has_key(arg, 'dir')
        let dir = arg['dir'][0]
    else
        let dir = def_dir
    endif
    if !isdirectory(dir)
        echoerr "directory "..dir.." is not exist."
        return
    endif
    if has_key(arg, 'depth')
        let depth = str2nr(arg['depth'][0])
    else
        let depth = -1
    endif

    if depth == -1
        let glob_str = dir..'/**'
    else
        let glob_str = dir
        for i in range(depth)
            let glob_str .= '/*'
        endfor
    endif
    let res = []
    for fy in glob(glob_str, v:false, v:true)
        if match(fy, arg['name'][0]) != -1
            call add(res, fy)
        endif
    endfor
    if len(res) == 0
        echo 'no matched file is found.'
        return
    endif
    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines/3,
                \ 'col': &columns/3,
                \ 'nv_border': 'single',
                \ }
    call meflib#floating#select(res, config,
                \ function(expand('<SID>')..'find_cb', [res]))
endfunction

