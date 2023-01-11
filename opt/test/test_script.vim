scriptencoding utf-8

function! <SID>main() abort
    let txt = <SID>set_string()
    while 1
        let intxt = input("4 letters:\n")
        if len(intxt) != 4
            echo "\n"
            continue
        endif

        echo "\n"
        let ok = 0
        for i in range(4)
            if intxt[i] == txt[i]
                echohl Title
                echon 'o'
                echohl None
                let ok += 1
            elseif match(txt, intxt[i]) != -1
                echohl PreProc
                echon '~'
                echohl None
            else
                echohl Todo
                echon 'x'
                echohl None
            endif
        endfor
        if ok == 4
            echo 'Great!'
            break
        endif
    endwhile
endfunction

function! <SID>set_string() abort
    let txt_file = expand('%:h')..'/four_strings.txt'
    if filereadable(txt_file)
        let txt_list = readfile(txt_file)
        let idx = rand()%len(txt_list)
        return txt_list[idx]
    else
        echo txt_file.." not found."
        return "hoge"
    endif
endfunction

call <SID>main()
" please :source %
