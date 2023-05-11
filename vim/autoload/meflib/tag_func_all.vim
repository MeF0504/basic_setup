scriptencoding utf-8

let s:taginfo = {}

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

function! s:get_tag_info(tfile) abort
    if filereadable(a:tfile)
        for line in readfile(a:tfile)
            if line[0] ==# '!'
                continue
            endif
            let word = split(line, "\t")[0]
            let sfile = split(line, "\t")[1]
            let idx = match(line, '$/;"')+5
            let kind = line[idx:idx]
            if v:true
                let lst = match(line, "/^")+2
                let lend = match(line, '$/;"')-1
                let lstr = line[lst:lend]
                let lnum = s:get_line(sfile, lstr)
            else
                let lnum = 0
            endif
            let str = printf('%s|%d| %s', sfile, lnum, word)
            if has_key(s:taginfo, kind)
                call add(s:taginfo[kind], str)
            else
                let s:taginfo[kind] = [str]
            endif
        endfor
    endif
endfunction

function! meflib#tag_func_all#open() abort
    for tfile in tagfiles()
        call s:get_tag_info(tfile)
    endfor
    if empty(s:taginfo)
        echo "no tag information"
        return
    endif

    let kind = input(printf('kind [%s]? ', join(keys(s:taginfo), ' ')))
    if !has_key(s:taginfo, kind)
        echo "incorrect kind."
        return
    endif
    cgetexpr s:taginfo[kind]
    copen
endfunction

