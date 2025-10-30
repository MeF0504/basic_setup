scriptencoding utf-8

function! s:run_cmd(cmds) abort
    let exec_cmd = join(a:cmds)
    return system(exec_cmd)
endfunction

" ファイルの存在チェック
function! meflib#filejump#main() abort
    let line = getline('.')
    "           ↓full path  ↓expand var ↓expand cfile
    let fname = fnamemodify(expand(expand('<cfile>')), ':p')
    let lnum = 1
    let yn = 'y'

    if line =~# '^\s*File ".*", line \d*,'
        " python error
        echo "python error line."
        let idx_l = stridx(line, '"')+1
        let idx_r = stridx(line, '"', idx_l)-1
        let fname = line[idx_l:idx_r]
        let idx_l = stridx(line, ', line ', idx_r)+7
        let idx_r = stridx(line, ', in', idx_l)-1
        let lnum = line[idx_l:idx_r]
    elseif line =~# '^.*:[0-9]\+:.*$'
        " grep results
        echo "grep result"
        let idx_r = stridx(line, ':')-1
        let fname = line[:idx_r]
        let idx_l = idx_r+2
        let idx_r = stridx(line, ':', idx_l)-1
        let lnum = line[idx_l:idx_r]
    elseif isdirectory(fname)
        " directory
        let yn = input(printf('%s: directory. open in new tab? (y/s/[n]): ', fname))
        if match(['y', 's'], yn) == -1
            let yn = 'n'
        endif
    elseif filereadable(fname)
        " file
        let yn = input(printf('%s: file. open in new tab? (y/s/a/[n]): ', fname))
        if match(['y', 's', 'a'], yn) == -1
            let yn = 'n'
        endif
    elseif fname[:6] ==# 'http://' || fname[:7] ==# 'https://'
        " URL
        let cmd = meflib#basic#get_exe_cmd()
        if !empty(cmd)
            let yn = input(printf('"%s": web url. open? (y/[n])', fname))
            if (yn == 'y')
                call s:run_cmd([cmd, fname])
            endif
        else
            echo 'command to open web url is not found.'
        endif
        return
    else
        echo printf('%s not exist.', fname)
        return
    endif

    if yn ==# 'y'
        execute "tabnew ".fname
        execute lnum
    elseif yn ==# 's'
        let cmd = meflib#basic#get_exe_cmd()
        if !empty(cmd)
            call s:run_cmd([cmd, fname])
        else
            echo 'command to open the file is not found.'
        endif
    elseif yn ==# 'a'
        if executable('aftviewer')
            execute printf('Terminal aftviewer %s -c', fname)
        else
            echo 'aftviewer command is not found.'
        endif
    endif
endfunction

