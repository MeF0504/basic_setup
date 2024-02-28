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

function! meflib#tag_func_all#open() abort
    let s:taginfo = {}
    for tfile in tagfiles()
        if has('python3')
            python3 set_tag_info(vim.eval("tfile"))
        else
            call s:set_tag_info(tfile)
        endif
    endfor
    if empty(s:taginfo)
        echo "no tag information"
        return
    endif

    let kind = input(printf('kinds [%s]? ', join(keys(s:taginfo), ' ')))
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

