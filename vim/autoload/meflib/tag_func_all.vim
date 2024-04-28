scriptencoding utf-8

if has('python3')
    python3 import vim
    py3file <sfile>:h/tag_func_all.py
endif

function! s:get_line(sfile, string) abort
    if filereadable(a:sfile)
        let lines = readfile(a:sfile)
        for i in range(len(lines))
            let line = lines[i]
            if line ==# a:string
                return i+1
            endif
        endfor
    endif
    return 0
endfunction

function! s:set_tag_info(tfile) abort
    if filereadable(a:tfile)
        for line in readfile(a:tfile)
            if line[0] ==# '!'
                continue
            endif
            let word = split(line, "\t")[0]
            let sfile = split(line, "\t")[1]
            let idx = match(line, '$/;"')+5
            if idx < 0+5
                continue
            endif
            let kind = line[idx:idx]
            if v:true
                let lst = match(line, "/^")+2
                let lend = match(line, '$/;"')-1
                let lstr = line[lst:lend]
                let lnum = s:get_line(sfile, lstr)
            else
                let lnum = 0
            endif
            let str = printf('%s|%d| %s (%s)', sfile, lnum, word, kind)
            if has_key(s:taginfo, kind)
                call add(s:taginfo[kind], str)
            else
                let s:taginfo[kind] = [str]
            endif
        endfor
    endif
endfunction

function! s:show_kinds() abort
    if empty(&filetype)
        echo 'filetype is not set'
        return
    endif
    let ctags_cmd = meflib#get('ctags_config', 'command', 'ctags')
    if !executable(ctags_cmd)
        echohl ErrorMsg
        echomsg printf('%s is not executable', ctags_cmd)
        echohl None
        return
    endif
    if &filetype == 'cpp'
        let ft = 'c++'
    else
        let ft = &filetype
    endif
    let cmd = [ctags_cmd, printf('--list-kinds=%s', ft)]
    if !has('nvim')
        let cmd = join(cmd, ' ')
    endif
    for res in systemlist(cmd)
        echo res
    endfor
endfunction

function! meflib#tag_func_all#comp(arglead, cmdline, cursorpos) abort
    let opts = ['kinds', 'tagfiles']
    if len(split(a:cmdline, ' ', 1)) > 2
        return ['']
    endif
    let res = filter(opts, '!stridx(tolower(v:val), a:arglead)')
    return res
endfunction

function! meflib#tag_func_all#open(arg='') abort
    if empty(a:arg)
        " pass
    elseif a:arg == 'kinds'
        call s:show_kinds()
        return
    elseif a:arg == 'tagfiles'
        let idx = 1
        for tf in tagfiles()
            echo printf('%d %s', idx, tf)
            let idx += 1
        endfor
        return
    else
        echo 'incorrect argument.'
        return
    endif

    let s:taginfo = {}
    for tfile in tagfiles()
        if has('python3')
            python3 set_tag_info(vim.eval("tfile"), vim.eval("s:taginfo"))
        else
            call s:set_tag_info(tfile)
        endif
    endfor
    if empty(s:taginfo)
        echo "no tag information"
        return
    endif

    let kind = input(printf('kinds [%s] | all? ', join(keys(s:taginfo), ' ')))
    if empty(kind)
        normal! :
        echo "empty cancel"
        return
    elseif kind ==# 'all'
        let kind = join(keys(s:taginfo), '')
    endif
    let res = []
    for k in kind
        if has_key(s:taginfo, k)
            let res += s:taginfo[k]
        else
            echomsg printf(' skip %s: incorrect kind.', k)
        endif
    endfor
    cgetexpr res
    let title = printf(' TagFuncAll ("%s")', kind)
    " :h setqflist-examples
    call setqflist([], 'a', {'title': title})
    copen
endfunction

