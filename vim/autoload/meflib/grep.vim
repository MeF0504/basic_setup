scriptencoding utf-8

" 自作grep
" 補完
function! meflib#grep#comp(arglead, cmdline, cursorpos) abort
    let cur_opt = split(a:cmdline, ' ', 1)[-1]
    if (match(cur_opt, '=') == -1)
        let opts = ['wd', 'dir', 'ex']
        return filter(map(opts, 'v:val."="'), '!stridx(v:val, a:arglead) && match(a:cmdline, v:val)==-1')
    elseif cur_opt =~ 'dir='
        let arg = split(cur_opt, '=', 1)[1]
        let files = split(glob(arg..'*'), '\n')
        if !empty(files)
            return map(files+['opened'], "'dir='..v:val")
        else
            return []
        endif
    else
        return []
    endif
endfunction

function! <SID>echo_gregrep_help()
    echo "usage..."
    echo ":GREgrep [wd=word] [dir=dir_path] [ex=extention]"
    echo "wd ... text to search. if a word is put in <>, search it as a word."
    echo "dir ... path to root directory or file for search."
    echo "        if dir=opened, search files in buffer"
    echo "ex ... file extention of target files."
    echo "       if ex=None, search all files."
    echo "e.g. :GREgrep wd=hoge ex=.vim dir=%:h:h"
    echo "e.g. :GREgrep wd=fuga ex=None"
    echo "e.g. :GREgrep wd=<are> dir=opened"
endfunction

function! meflib#grep#main(...)
    let def_dir = '.'
    if meflib#get('get_top_dir', 0) == 1
        let top_dir = meflib#basic#get_top_dir(expand('%:h'))
        if !empty(top_dir)
            let def_dir = top_dir
        endif
    endif
    let def_wd = expand('<cword>')
    let is_word = v:true
    if meflib#basic#special_win(win_getid())
        let def_ft = 'None'
    elseif &buftype == 'terminal'
        let def_ft = 'None'
    else
        let def_ft = '.'..expand('%:e')
    endif
    let ex_dirs = meflib#get('exclude_dirs', [])
    let def_all = v:false

    if a:0 == '0'
        let l:word = def_wd
        let l:ft = def_ft
        let l:dir = def_dir
        let l:all = def_all
    else
        let arg = meflib#basic#analythis_args_eq(a:1)

        if !has_key(arg, "wd") && !has_key(arg, "ex") && !has_key(arg, "dir")
            call s:echo_gregrep_help()
            return
        endif

        if has_key(arg, "wd")
            let l:word = arg["wd"]
            if l:word[0]=='<' && l:word[-1:]=='>'
                let is_word = v:true
                let l:word = l:word[1:-2]
            else
                let is_word = v:false
            endif
        else
            let l:word = def_wd
        endif
        if has_key(arg, 'ex')
            let l:ft = arg['ex']
        else
            let l:ft = def_ft
        endif
        let l:dir = has_key(arg, "dir") ? expand(arg["dir"]) : def_dir
        let l:all = has_key(arg, "all") ? str2nr(arg["all"]) : def_all
    endif
    let l:word = fnameescape(l:word)

    let is_opened = 0
    if l:dir == 'opened'
        let is_opened = 1
    elseif !isdirectory(l:dir)
        echo 'input directory "' . l:dir . '" does not exist.'
        return
    endif

    if is_opened
        let l:dir = ''
        for i in range(1, tabpagenr('$'))
            let bufnrs = tabpagebuflist(i)
            for bn in bufnrs
                let bufname = bufname(bn)
                if (match(l:dir, bufname) == -1) && filereadable(bufname)
                    let l:dir .= ' '.bufname
                endif
            endfor
        endfor
    else
        let l:dir = substitute(l:dir, ' ', '\\ ', 'g')
    endif

    if &grepprg == "internal"
        if is_opened
            let files = l:dir
        elseif l:ft == 'None'
            let files = l:dir..'/**/*'
        else
            let files = l:dir..'/**/*'..l:ft
        endif
        if is_word
            let bra = '\<'
            let ket = '\>'
        else
            let bra = ''
            let ket = ''
        endif
        if !l:all
            execute printf('set wildignore+=%s', join(ex_dirs, ','))
        endif
        execute printf('vimgrep /%s%s%s/j %s', bra, l:word, ket, files)
        if !l:all
            execute printf('set wildignore-=%s', join(ex_dirs, ','))
        endif
    elseif &grepprg =~ "grep\ -[a-z]*r[a-z]*"
        " cclose
        "wincmd b
        if l:ft == 'None'
            let l:ft = ''
        else
            let l:ft = ' --include=\*' . l:ft
        endif
        let wd_opt = is_word ? ' -w ' : ''
        if l:all
            let ex_dir_opt = ""
        else
            let ex_dir_opt = printf("--exclude-dir={%s}", join(ex_dirs, ','))
        endif

        " execute printf('grep! %s %s "%s" %s', l:ft, wd_opt, l:word, l:dir)
        " いちいちterminalに戻らない様になる
        " https://zenn.dev/skanehira/articles/2020-09-18-vim-cexpr-quickfix
        let cmd = printf("cgetexpr system('%s %s %s %s \"%s\" %s')",
                    \ &grepprg, l:ft, wd_opt, ex_dir_opt, l:word, l:dir)
        " quickfix_title をいい感じにするためにexecute を使う
        execute cmd
        " cwindow -> copen to check if grep is finished.
        copen
    else
        echo "not supported grepprg"
    endif
endfunction

