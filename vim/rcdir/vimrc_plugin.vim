"vim script encording setting
set encoding=utf-8
scriptencoding utf-8

" vim (almost) self-made function file

" 関数の引数解析用関数 (key=arg){{{
function! s:analythis_args(arg) abort
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
" }}}

" 関数の引数解析用関数 (-opt arg) {{{
function! s:analythis_args2(args, args_config) abort
    let args = split(a:args, ' ')
    let res = {'no_opt':[]}
    let skip_cnt = -1
    " echo args
    for i in range(len(args))
        let arg = args[i]
        " echo '<>'.i.':'.arg
        let opt_num = 0
        if arg[0]=='-'
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
"}}}

"単語のハイライト情報をget "{{{
"from http://cohama.hateblo.jp/entry/2013/08/11/020849
function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  let ctermopt = ''
  let guiopt = ''
  let termopts = ['bold', 'italic', 'reverse', 'inverse', 'standout', 'underline', 'undercurl', 'strike']
  for termopt in termopts
      if synIDattr(a:synid, termopt, 'cterm') == 1
          let ctermopt .= termopt.','
      endif
      if synIDattr(a:synid, termopt, 'gui') == 1
          let guiopt .= termopt.','
      endif
  endfor
  if len(ctermopt) > 0
      let ctermopt = ctermopt[:-2]
  endif
  if len(guiopt) > 0
      let guiopt = guiopt[:-2]
  endif
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ 'ctermopt': ctermopt,
        \ "guifg": guifg,
        \ "guibg": guibg,
        \ 'guiopt': guiopt,
        \ }
endfunction

function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  let s_info = "name: " . baseSyn.name
  if has('gui_running')
      let s_info .= "  guifg: " . baseSyn.guifg
      let s_info .= "  guibg: " . baseSyn.guibg
      let s_info .= "  gui: " . baseSyn.guiopt
  else
      let s_info .= "  ctermfg: " . baseSyn.ctermfg
      let s_info .= "  ctermbg: " . baseSyn.ctermbg
      let s_info .= "  cterm: ". baseSyn.ctermopt
  endif
  echo s_info
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  let s_info = "name: " . linkedSyn.name
  if has('gui_running')
      let s_info .= "  guifg: " . linkedSyn.guifg
      let s_info .= "  guibg: " . linkedSyn.guibg
      let s_info .= "  gui: " . linkedSyn.guiopt
  else
      let s_info .= "  ctermfg: " . linkedSyn.ctermfg
      let s_info .= "  ctermbg: " . linkedSyn.ctermbg
      let s_info .= "  cterm: " . linkedSyn.ctermopt
  endif
  echo s_info
endfunction
command! SyntaxInfo call s:get_syn_info()
" }}}

"vimでbinary fileを閲覧，編集 "{{{
let s:bin_fts = ''
function! <SID>BinaryMode()
    " :h using-xxd
    " vim -b : edit binary using xxd-format!
    let ext = '.'.expand('%:e')
    if ext == '.'
        let ext = expand('%:t')
    endif
    if match(split(s:bin_fts, ','), '*'.ext) != -1
        echo 'already set '.ext
        return
    endif
    let s:bin_fts .= '*'.ext.','
    augroup Binary
        autocmd!
        execute "autocmd BufReadPre   ".s:bin_fts." let &bin=1"
        execute "autocmd BufReadPost  ".s:bin_fts." if &bin | %!xxd"
        execute "autocmd BufReadPost  ".s:bin_fts." set ft=xxd | endif"
        execute "autocmd BufWritePre  ".s:bin_fts." if &bin | %!xxd -r"
        execute "autocmd BufWritePre  ".s:bin_fts." endif"
        execute "autocmd BufWritePost ".s:bin_fts." if &bin | %!xxd"
        execute "autocmd BufWritePost ".s:bin_fts." set nomod | endif"
    augroup END
    e!
endfunction

command! BinMode call <SID>BinaryMode()

" }}}

" 開いているfile一覧 {{{
let g:l_cur_winID = win_getid()

function! s:file_list() abort
    let l:fnames = {}
    " tab number
    for i in range(1,tabpagenr('$'))
        "buffer number of each window
        for bufn in tabpagebuflist(i)
            let l:fname = bufname(bufn)
            if (len(l:fname) > 0) && (l:fname[0] == '/')
                let l:fname = fnamemodify(l:fname,':~')
            endif
            let l:fnames[i . "-" . bufn] = l:fname
        endfor
    endfor

    let l:search_name = '.'
    while 1
        redraw!
        " for in # of tab
        for i in range(1,tabpagenr('$'))
            let l:disp = 0
            let l:tab_files = printf("%3d", i)
            let l:tab_files .= ' '
            " for in # of window in 1 tab
            for j in range(1, tabpagewinnr(i, '$'))
                let win_winID = win_getid(j, i)
                let bufn = tabpagebuflist(i)[j-1]
                if (v:version > 802) || ((v:version == 802) && has('patch1727'))
                    let curpos = getcurpos(win_winID)
                    let line_col = ' ('.curpos[1].'-'.curpos[2].')'
                else
                    let line_col = ''
                endif
                "check if 'search word' in file name.
                if match(l:fnames[i . "-" . bufn], l:search_name) != -1
                    let l:disp = 1
                endif

                let mod = getbufvar(bufn, '&modified') ? '[+]' : ''
                let l:flist =  '[ ' . l:fnames[i . "-" . bufn] . mod . line_col . ' ] '
                if getbufvar(bufn, '&filetype') == 'qf'
                    let l:flist = '[ QuickFix' . mod . ']'
                endif
                let l:tab_files .= l:flist
            endfor
            if l:disp == 1
                if tabpagenr() == i
                    echohl Search | echo l:tab_files | echohl None
                else
                    echo l:tab_files
                endif
            else
                echohl Comment | echo l:tab_files | echohl None
            endif
        endfor
        let l:tabnr = input("'#' :jump to tab / 'q' :wuit / 'p' :previous tab / 'FileName' :search file :>> ")
        " quit
        if l:tabnr == "q"
            redraw!
            return
        " move to previous tab
        elseif l:tabnr == "p"
            let l:tabnr = win_id2tabwin(g:l_cur_winID)[0]
        " check l:tabnr is number
        elseif str2nr(l:tabnr) != 0
            let l:tabnr = str2nr(l:tabnr)
        " set search word
        else
            let l:search_name = l:tabnr
            continue
        endif
        if (1 <= l:tabnr ) && (l:tabnr <= tabpagenr("$") )
            " get current page number
            let g:l_cur_winID = win_getid()
            execute("normal! " . l:tabnr . "gt")
            redraw!
            return
        endif
    endwhile
endfunction

command! Tls call s:file_list()

nnoremap <silent> <leader>l :Tls<CR>

" }}}

" window setiing function {{{
function! s:window_mode() abort
    if !exists("s:wmode_on")
        let s:wmode_on = 1
        "save old map
        let g:l_wmode_old_map = {}
        let g:l_wmode_map_strs = ["<right>", "l", "<left>", "h", "<up>", "k", "<down>", "j", "i", "a", "s", "I", "A", "S", "R","+","-"]
        for st in g:l_wmode_map_strs
            let g:l_wmode_old_map[st] = maparg(st, 'n',0,1)
        endfor

        "map change window
        nnoremap <right> <c-w>>
        nnoremap l <c-w>>
        nnoremap <left> <c-w><
        nnoremap h <c-w><
        nnoremap <up> <c-w>+
        nnoremap k <c-w>+
        nnoremap <down> <c-w>-
        nnoremap j <c-w>-
        nnoremap i <Nop>
        nnoremap a <Nop>
        nnoremap s <Nop>
        nnoremap I <Nop>
        nnoremap A <Nop>
        nnoremap S <Nop>
        nnoremap R <Nop>

        "change gui font size
        if has("gui")
            function! s:set_font_size(pm)
                let l:fl = strridx(&guifont, 'h')
                let l:font_size = str2nr(&guifont[fl+1:])
                if a:pm == '-'
                    let l:font_size -= 1
                elseif a:pm == '+'
                    let l:font_size += 1
                else
                    return
                endif
                execute("set guifont=" . &guifont[:l:fl] . l:font_size)
            endfunction

            command! WMPlus call s:set_font_size('+')
            command! WMMinus call s:set_font_size('-')
            nnoremap <silent> + :WMPlus<CR>
            nnoremap <silent> - :WMMinus<CR>
        else
            nmap + +
            nmap - -
        endif

        "show mode in statusline
        "set statusline+=\ [WM]
        let s:old_st = &statusline
        let &statusline = "%f%m%r%h%w  %=[wimdow mode on]"
    else
        unlet s:wmode_on
        "remap
        for st in g:l_wmode_map_strs
            let l:st_map = g:l_wmode_old_map[st]
            if l:st_map == {}
                execute( "unmap " . st )
            else
                let l:opt = ''
                if l:st_map['silent']
                    let l:opt .= ' <silent> '
                endif
                if l:st_map['buffer']
                    let l:opt .= ' <buffer> '
                endif
                if l:st_map['nowait']
                    let l:opt .= ' <nowait> '
                endif
                if l:st_map['expr']
                    let l:opt .= ' <expr> '
                endif
                if l:st_map['noremap']
                    let l:map_str = 'nnoremap '
                else
                    let l:map_str = 'nmap '
                endif
                execute(l:map_str . l:opt . l:st_map['lhs'] . " " . l:st_map['rhs'] )
            endif
        endfor
        "delete changing font size command
        if has('gui')
            delcommand WMPlus
            delcommand WMMinus
        endif

        "unlet global variables
        unlet g:l_wmode_old_map
        unlet g:l_wmode_map_strs

        "set statusline-=\ [WM]
        let &statusline = s:old_st
    endif
endfunction

command! Wmode call s:window_mode()
nnoremap <silent> <Leader>w :Wmode<CR>
" }}}

""" #で行末から括弧を見つけたり、次のcase文を見つけたりしてとぶ {{{
function! <SID>chk_braket_python()
    let l:bra = "def if for with try"
    let l:ak = ", else,elif , , except"

    function! s:match_bak_python(bak_list)
        for i in a:bak_list
            let i .= " "
            let l:idx = stridx(getline('.'), i)
            if l:idx != -1
                return l:idx
            endif
        endfor
        return -1
    endfunction

    if &expandtab
        let l:tab = " "
        "for i in range(&tabstop)
        "    let l:tab .= " "
        "endfor
    else
        let l:tab = "\t"
    endif

    let l:braList = split(l:bra, ' ')
    let l:akList = split(l:ak, ' ')

    if len(l:braList) != len(l:akList)
        echo "list length don't match."
        return ""
    endif

    for i in range(0, len(l:braList)-1)
        let b = l:braList[i]
        let a = l:akList[i]
        let b = [b]
        let a = split(a, ',')
        let l:idx = s:match_bak_python(b + a)

        if l:idx != -1
            if l:idx == 0
                let l:lnspace = ''
            else
                let l:lnspace = getline('.')[:l:idx-1]
            endif
            for l in range(line('.')+1, line('$'))
                let l:linestr = getline(l)
                if (match(l:linestr, '\w') != -1) && (match(l:linestr, '\w') <= l:idx)
                    return l . "gg"
                endif
            endfor
        endif
    endfor

    " current lineが空で、next lineに文字があれば
    " next lineと同じインデントを上方検索してjump
    let l:nidx = match(getline(line('.')+1), '\w')
    if (getline('.') == '') && (l:nidx != -1)
        for l_tmp in range(1, line('.')-1)
            let l = line('.') - l_tmp
            let l:linestr = getline(l)
            if (match(l:linestr, '\w') != -1) && (match(l:linestr, '\w') <= l:nidx)
                return l . "gg"
            endif
        endfor
    endif

    " next lineがcurrent lineよりインデントが小さければ
    " next lineと同じインデントを上方検索してjump
    let l:cidx = match(getline(line('.')), '\w')
    let l:nidx = match(getline(line('.')+1), '\w')
    if (l:cidx != -1) && (l:nidx != -1) && (l:nidx < l:cidx)
        let l:iniword = split(getline("."), l:tab)[0][0]
        "doesn't work if current line is comment line
        if (l:iniword == "#") || (l:iniword == '"') || (l:iniword == "'")
            return ""
        endif

        for l_tmp in range(1, line('.')-1)
            let l = line('.') - l_tmp
            let l:linestr = getline(l)
            if (match(l:linestr, '\w') != -1) && (match(l:linestr, '\w') < l:cidx)
                return l . "gg"
            endif
        endfor
    endif

    return ""
endfunction

function! <SID>chk_braket()
    """ language specific type
    if &filetype == "vim"
        let l:bra = "if function for while"
        let l:ak = "else,elseif , , ,"
        let l:ket = "endif endfunction endfor endwhile"
    elseif (&filetype == "c") || (&filetype == "cpp")
        let l:bra = "#if #ifdef #ifndef switch"
        let l:ak = "#else #else #else case"
        let l:ket = "#endif #endif #endif default"
    elseif &filetype == "html"
        let l:bra = '<html <head <body <script <style <p'
        let l:ak = ', , , , , ,'
        let l:ket = '</html </head </body </script </style </p'
    elseif (&filetype == 'sh') || (&filetype == 'zsh')
        let l:bra = "if for while case"
        let l:ak = "else,elif , , .)"
        let l:ket = "fi done done esac"
    elseif (&filetype == "python")
        let l:res = <SID>chk_braket_python()
        if l:res != ""
            return l:res
        endif
        let l:bra = ""
        let l:ak = ""
        let l:ket = ""
    else
        let l:bra = ""
        let l:ak = ""
        let l:ket = ""
    endif

    " configure {{{
    function! s:match_bak(line, bak_list)
        for i in a:bak_list
            if a:line[0][:len(i)-1] =~ i
                return 1
            endif
        endfor
        return 0
    endfunction

    if &expandtab
        let l:tab = " "
    else
        let l:tab = "\t"
    endif

    let l:braList = split(l:bra, ' ')
    let l:akList = split(l:ak, ' ')
    let l:ketList = split(l:ket, ' ')

    if len(l:braList) != len(l:akList)
        echo "list length don't match."
        return ""
    endif
    if len(l:braList) != len(l:ketList)
        echo "list length don't match."
        return ""
    endif
    " }}}

    for i in range(0, len(l:braList)-1)
        let b = l:braList[i]
        let a = l:akList[i]
        let k = l:ketList[i]
        let b = [b]
        let a = split(a, ',')
        let k = [k]

        let l:cline = split(getline("."), l:tab)
        if len(l:cline) == 0
            return
        endif

        " start from bra or ak {{{
        if s:match_bak(cline, b + a)
            let l:count = 1
            for l in range(line('.')+1, line('$'))
                let l:linestr = split(getline(l), l:tab)
                if len(l:linestr) == 0
                    continue
                endif
                " find bra ... count up.
                if s:match_bak(l:linestr, b)
                    let l:count += 1
                    continue
                endif
                " find ak ... if count=1, finish
                if s:match_bak(l:linestr, a)
                    if l:count == 1
                        return l . "gg"
                    endif
                endif
                " find ket ... if count=1, finish. else, count down
                if s:match_bak(l:linestr, k)
                    if l:count == 1
                        return l . "gg"
                    else
                        let l:count -= 1
                        continue
                    endif
                endif
            endfor
        " }}}
        " start from ket {{{
    elseif s:match_bak(l:cline, k)
            let l:count = 1
            for ltmp in range(1, line('.')-1)
                let l = line('.') - ltmp
                let l:linestr = split(getline(l), l:tab)
                if len(l:linestr) == 0
                    continue
                endif
                " find bra ... if count=1, finish. else, count down
                if s:match_bak(l:linestr, b)
                    if l:count == 1
                        return l . "gg"
                    else
                        let l:count -= 1
                        continue
                    endif
                endif
                " find ket ... count up.
                if s:match_bak(l:linestr, k)
                    let l:count += 1
                    continue
                endif
            endfor
        endif
        " }}}
    endfor

    """ find braket {{{
    let l:src_strs = ["{", "(", "[", "}", ")", "]"]
    for l:ss in l:src_strs
        let l:idx = strridx(getline("."), l:ss)
        if l:idx == -1
            continue
        endif
        if l:idx == len(getline("."))-1
            return "$%"
        else
            return "$F" . l:ss . "%"
        endif
    endfor
    " }}}
    return ""
endfunction

"{{{ sometimes this function does't work as expected
function! <SID>chk_braket_test()
    """ language specific type
    if &filetype == "vim"
        let l:bra = "if if function for"
        let l:ak = "else elseif None None"
        let l:ket = "endif endif endfunction endfor"
        let l:com = '\"'
    elseif (&filetype == "c") || (&filetype == "cpp")
        let l:bra = "#if #ifdef #ifndef switch"
        let l:ak = "#else #else #else case"
        let l:ket = "#endif #endif #endif default"
        let l:com = "/"
    elseif (&filetype == "python")
        let l:res = <SID>chk_braket_python()
        if l:res != ""
            return l:res
        endif
        let l:bra = ""
        let l:ak = ""
        let l:ket = ""
        let l:com = "#"
    else
        let l:bra = ""
        let l:ak = ""
        let l:ket = ""
        let l:com = ""
    endif

    " configure {{{
    let l:braList = split(l:bra, ' ')
    let l:akList = split(l:ak, ' ')
    let l:ketList = split(l:ket, ' ')

    if len(l:braList) != len(l:akList)
        echo "list length don't match."
        return ""
    endif
    if len(l:braList) != len(l:ketList)
        echo "list length don't match."
        return ""
    endif
    " }}}

    for i in range(len(l:braList)-1)
        let b = l:braList[i]
        let a = l:akList[i]
        let k = l:ketList[i]

        if a == "None"
            let a = ""
        endif

        let l:cline = getline(".")
        let l:bidx = match(l:cline, '\<' . b . '\>')
        let l:aidx = match(l:cline, '\<' . a . '\>')
        let l:kidx = match(l:cline, '\<' . k . '\>')
        if (l:bidx != -1) || (l:aidx != -1)
            let l = max([l:bidx, l:aidx])
            call cursor(line('.'), l+1)
            let l:line = searchpair(b, a, k, 'zW', 'getline(".") =~ "^\\s*' . l:com . '"')
            return l:line . "gg"
        endif
        if (l:kidx != -1)
            call cursor(line('.'), l:kidx)
            let l:line = searchpair(b, '', k, 'bzW', 'getline(".") =~ "^\\s*' . l:com . '"')
            return l:line . "gg"
        endif
    endfor
endfunction
" }}}
nnoremap <expr> # <SID>chk_braket()
vnoremap <expr> # <SID>chk_braket()

" }}}

" termonal commandを快適に使えるようにする {{{
"" http://koturn.hatenablog.com/entry/2018/02/12/140000
let s:term_opts = ['win', 'term']
let s:term_win_opts = ['S', 'V', 'F']
function! s:complete_term(arglead, cmdline, cursorpos) abort
    ":h :command-completion-custom
    let arglead = tolower(a:arglead)
    let cmdline = tolower(a:cmdline)
    let opt_idx = strridx(cmdline, '-')
    let end_space_idx = strridx(cmdline, ' ')
    " return ['-1-'.a:arglead, '-2-'.a:cmdline, '-3-'.a:cursorpos, '-4-'.a:cmdline[opt_idx:]]
    if arglead[0] == '-'
        " select option
        let res = []
        for opt in s:term_opts
            let res += ['-'.opt]
        endfor
        return filter(res, '!stridx(tolower(v:val), arglead)')
    elseif cmdline[opt_idx:end_space_idx-1] == '-win'
        return s:term_win_opts
    elseif cmdline[opt_idx:end_space_idx-1] == '-term'
        if exists('*term_list')
            let term_names = filter(map(term_list(), 'bufname(v:val)'), '!stridx(tolower(v:val), arglead)')
        else
            if has('nvim')
                let st_idx = 6
                let term_head = 'term://'
            else
                let st_idx = 0
                let term_head = '!'
            endif
            let term_list = []
            for i in range(1, tabpagenr('$'))
                for j in tabpagebuflist(i)
                    let bname = bufname(j)
                    if bname[:st_idx] == term_head
                        let term_list += [bname]
                    endif
                endfor
            endfor
            let term_names = filter(term_list, '!stridx(tolower(v:val), arglead)')
        endif
        return term_names
    else
        " shell コマンド一覧が得られたら嬉しい
        " $PATHでfor文を回す手もあるが，時間が掛かりそう...
        return []
    endif
endfunction

function! s:open_term(bufname) abort
    let bufn = bufnr(a:bufname)
    if bufn == -1
        " throw 'E94: No matching buffer for ' . a:bufname
        echoerr 'No matching buffer for "' . a:bufname . '"'
        return 1        " 以上終了ということにしよう
    elseif exists('*term_list') && index(term_list(), bufn) == -1
        " throw a:bufname . 'is not a terminal buffer'
        echoerr '"' . a:bufname . '"is not a terminal buffer'
        return 1        " 以上終了ということにしよう
    endif
    let winids = win_findbuf(bufn)
    if empty(winids)
        execute term_getsize(bufn)[0] 'new'
        execute 'buffer' bufn
    else
        call win_gotoid(winids[0])
    endif
    return 0
endfunction

" https://qiita.com/shiena/items/1dcb20e99f43c9383783
let s:term_cnt = 1
function! s:open_term_win(opts)
    " 日本語Windowsの場合`ja`が設定されるので、入力ロケールに合わせたUTF-8に設定しなおす
    let env = {}
    if executable('locale.exe')
        let env['LANG'] = systemlist('"locale.exe" -iU')[0]
    endif

    " remote連携のための設定
    if has('clientserver')
        call extend(env, {
                    \ 'GVIM': $VIMRUNTIME,
                    \ 'VIM_SERVERNAME': v:servername,
                    \ })
    endif

    " term_startでgit for windowsのbashを実行する
    let term_opt = split(a:opts, ' ')
    if len(term_opt) == 0
        let term_opt = ['bash.exe', '-l']
        let term_fin = 'close'
    else
        let term_fin = 'open'
    endif
    call term_start(term_opt, {
                \ 'term_name': '!'.term_opt[0].'_'.s:term_cnt,
                \ 'term_finish': term_fin,
                \ 'curwin': v:true,
                \ 'cwd': $USERPROFILE,
                \ 'env': env,
                \ })
    let s:term_cnt += 1
endfunction

function! s:Terminal(...) abort
    if !has('terminal') && !has('nvim')
        echoerr "this vim doesn't support terminal!!"
        return
    endif

    let args_config = {'win':1, 'term':1}
    if a:0 == 0
        let opts = ''
    else
        let opts = a:1
    endif
    let opts = s:analythis_args2(opts, args_config)

    if has_key(opts, 'win')
        let win_opt = opts['win'][0]
    elseif exists('g:l_term_default')
        let win_opt = g:l_term_default
    else
        let win_opt = 'S'
    endif
    if match(s:term_win_opts, win_opt) == -1
        let win_opt = 'S'
    endif

    let term_opt = ''
    if has('win32')
        if has_key(opts, 'term')
            let res = s:open_term(opts['term'][0])
            if res != 0
                " can't find buffer
                return
            endif
            if mode() != 't'
                normal! i
            endif
            return
        else
            if win_opt == 'S'
                botright split
            elseif win_opt == 'V'
                botright vertical split
            elseif win_opt == 'F'
                tabnew
            else
                echo 'not a supported option. return'
                return
            endif
        endif
        let term_opt .= ' '.join(opts['no_opt'])
        call s:open_term_win(term_opt)

    else
        if has('nvim')
            if has_key(opts, 'term')
                let res = s:open_term(opts['term'][0])
                if res != 0
                    " can't find buffer
                    return
                endif
                if mode() != 't'
                    startinsert " neovimはstartinsertでTeminal modeになる
                endif
                return
            else
                if win_opt == 'S'
                    botright split
                elseif win_opt == 'V'
                    botright vertical split
                elseif win_opt == 'F'
                    tabnew
                else
                    echo 'not a supported option. return'
                    return
                endif
            endif
            let term_opt .= join(opts['no_opt'])
            execute 'terminal '.term_opt
            " rename buffer
            execute "silent file ".substitute(expand('%'), ' ', '', 'g')
            startinsert

        else
            let term_header = ''
            if has_key(opts, 'term')
                let res = s:open_term(opts['term'][0])
                if res != 0
                    " can't find buffer
                    return
                endif
                if mode() != 't'
                    " startinsert は無効らしい
                    normal! i
                endif
                return
            else
                if win_opt == 'S'
                    let term_header = 'botright '
                elseif win_opt == 'V'
                    let term_header = 'botright vertical '
                elseif win_opt == 'F'
                    tabnew
                    let term_opt = ' ++curwin'.term_opt
                else
                    echo 'not a supported option. return'
                    return
                endif
            endif
            let term_opt .= ' '.join(opts['no_opt'])
            execute term_header.'terminal '.term_opt
            " rename buffer
            execute "silent file ".substitute(expand('%'), ' ', '', 'g')
        endif
    endif

    setlocal nolist
    setlocal foldcolumn=0
    setlocal nonumber
endfunction

command! -nargs=? -complete=customlist,s:complete_term  Terminal call s:Terminal(<f-args>)


" }}}

" ファイルの存在チェック {{{
function! <SID>ChkFileExist(...) abort
    function! s:get_v_area()
        "" https://nanasi.jp/articles/code/screen/visual.html
        let l:tmp = @@
        silent normal gvy
        let l:selected = @@
        let @@ = l:tmp
        return l:selected
    endfunction

    if a:0 == 0
        let l:path = s:get_v_area()
    else
        let l:path = ''
        for i in range(a:0)
            let l:path = l:path . a:[i+1] . ' '
            let l:path = l:path[:-2]
        endfor
    endif

    let l:path = expand(l:path)
    if isdirectory(l:path)
        let ec_str = '"' . l:path . '" exists: directory.'
        let ec_str .= ' open this directory in new tab? (y/[n])'
    elseif filereadable(l:path)
        let ec_str = '"' . l:path . '" exists: file.'
        let ec_str .= ' open this file in new tab? (y/[n])'
    else
        echo l:path . ' not exists.'
        return
    endif

    let l:yn = input(ec_str)
    if (l:yn == 'y') || (l:yn == 'yes')
        execute 'tabnew ' . l:path
    endif

endfunction

command! -nargs=? ChkExist call <SID>ChkFileExist(<f-args>)
vnoremap <Leader>f v:ChkExist<CR>
nnoremap <expr> <Leader>f ':ChkExist ' . expand('<cfile>') . '<CR>'
" }}}

"diff系command {{{

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
command! -nargs=1 -complete=file Diff vertical diffsplit <args>
"}}}

" 行単位で差分を取る {{{

function! <SID>diff_line(...) abort
    " http://t2y.hatenablog.jp/entry/20110210/1297338263
    let help_str = ":DiffLine [file1:]start1[-end1] [file2:]start2[-end2]\n"
                \."if file is not specified, use current file.\n"
                \." e.g. :DiffLine 5-6 test/test.txt:7"

    if a:0 != 2
        echo "illegal input.\n".help_str
        return
    endif

    let idx11 = strridx(a:1, ':')
    if idx11 == -1
        let file1 = '%'
    else
        let file1 = a:1[:idx11-1]
    endif
    let idx12 = stridx(a:1, '-', idx11)
    if idx12 == -1
        let st1 = str2nr(a:1[idx11+1:])
        let end1 = st1
    else
        let st1 = str2nr(a:1[idx11+1:idx12-1])
        let end1 = str2nr(a:1[idx12+1:])
    endif

    let idx21 = strridx(a:2, ':')
    if idx21 == -1
        let file2 = '%'
    else
        let file2 = a:2[:idx21-1]
    endif
    let idx22 = stridx(a:2, '-', idx21)
    if idx22 == -1
        let st2 = str2nr(a:2[idx21+1:])
        let end2 = st2
    else
        let st2 = str2nr(a:2[idx21+1:idx22-1])
        let end2 = str2nr(a:2[idx22+1:])
    endif
    " echo file1.' '.st1.' '.end1.' '.file2.' '.st2.' '.end2

    " file check
     if !filereadable(expand(file1))
         echo "unable to read ".file1."\n".help_str
         return
     endif
     if (bufname(file1)=='')
         echo file1." is not in buffer. please open that.\n".help_str
         return
     endif
     if !filereadable(expand(file2))
         echo "unable to read ".file2."\n".help_str
         return
     endif
     if (bufname(file2)=='')
         echo file2." is not in buffer. please open that.\n".help_str
         return
     endif

    " set python command
    if has('python3')
        command! -nargs=1 TmpPython python3 <args>
    elseif has('python')
        command! -nargs=1 TmpPython python <args>
    else
        echoerr 'this command requires python or python3.'
        return
    endif

    " condition check
    if (st1 > end1) || (st2 > end2)
        echo "start is larger than end.\n".help_str
    endif
    " if end1 > line('$', win_findbuf(bufnr(file1))[0])
    "     echo "input number is larger than EOF.\n".help_str
    "     return
    " endif
    " if end2 > line('$', win_findbuf(bufnr(file2))[0])
    "     echo "input number is larger than EOF.\n".help_str
    "     return
    " endif

    let l1 = getbufline(file1, st1, end1)
    let l2 = getbufline(file2, st2, end2)

    pclose
    if a:0 == 2
        silent 5split DiffLine
    else
        silent 10split DiffLine
    endif
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    setlocal nowrap
    setlocal nobuflisted
    setlocal previewwindow
    setlocal nofoldenable

    TmpPython << EOF
import vim
import difflib

line1 = vim.eval('l1')
line2 = vim.eval('l2')

d = difflib.Differ()
ret = '\n'.join(d.compare(line1, line2)).split('\n')

# print(ret)
for r in ret:
    if r != '':
        vim.current.buffer.append(r)
EOF

    wincmd p
    delcommand TmpPython
endfunction

command! -nargs=* -complete=file DiffLine call <SID>diff_line(<f-args>)

" }}}

" 自作grep {{{
function! <SID>echo_gregrep_help()
    echo "usage..."
    echo ":GREgrep [wd=word] [dir=dir_path] [ex=extention]"
    echo "wd ... search word."
    echo "dir ... path to root directory or file for search."
    echo "        if dir=opened, search files in buffer"
    echo "ex ... file extention of target files."
    echo "       if ex=None, search all files."
endfunction

function! Mygrep(...)
    "args keywords ... wd, ex, dir
    "wd  ... search word.
    "ex  ... file extention.
    "dir ... search directory.
    "e.g. :GREgrep wd=hoge ex=.vim dir=%:h/../../
    "e.g. :GREgrep wd=fuga ex=.py
    " if &modified == 1
    "     echo "file not saved!"
    "     return
    " endif
    if a:0 == '0'
        let l:word = expand('<cword>')
        let l:ft = '.' . expand('%:e')
        let l:dir = '.'
    else
        let arg = s:analythis_args(a:1)

        if !has_key(arg, "wd") && !has_key(arg, "ex") && !has_key(arg, "dir")
            call s:echo_gregrep_help()
            return
        endif

        if has_key(arg, "wd")
            let l:word = arg["wd"]
            let l:word .= arg["no_key"]
        else
            let l:word = expand('<cword>')
        endif
        let l:ft =  has_key(arg,  "ex") ? arg["ex"] : expand('%:e')
        let l:dir = has_key(arg, "dir") ? expand(arg["dir"]) : '.'
    endif

    let is_file = 0
    let is_opened = 0
    if filereadable(l:dir)
        let is_file = 1
    elseif l:dir == 'opened'
        let is_file = 1
        let is_opened = 1
    elseif !isdirectory(l:dir)
        echo 'input directory "' . l:dir . '" does not exist.'
        return
    endif
    if &grepprg == "internal"
        if is_file == 1
            echo 'searching file is not supported for grepprg=internal'
            return
        endif
        if l:ft == 'None'
            let l:ft = ''
        endif
        execute 'vimgrep /'.l:word.'/j '.l:dir.'/**/*'.l:ft
    elseif &grepprg =~ "grep\ -[a-z]*r[a-z]*"
        if is_opened == 1
            let l:dir = ''
            for i in range(1, tabpagenr('$'))
                let bufnrs = tabpagebuflist(i)
                for bn in bufnrs
                    let bufname = bufname(bn)
                    if match(l:dir, bufname) == -1
                        let l:dir .= ' '.bufname
                    endif
                endfor
            endfor
        else
            let l:dir=substitute(l:dir, ' ', '\\ ', 'g')
        endif
        " cclose
        "wincmd b
        if l:ft == 'None'
            let l:ft = ''
        else
            let l:ft = ' --include=\*' . l:ft
        endif
        execute 'grep!'.l:ft.' "'.l:word.'" '.l:dir
        " botright copen
        " set statusline="%t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ' '} "
    else
        echo "not supported grepprg"
    endif
endfunction
command! -nargs=? Gregrep call Mygrep(<f-args>)
command! -nargs=? GREgrep Gregrep


" }}}

" {{{ 今自分がどの関数/class/for/if内にいるのか表示する
function! <SID>chk_current_position_python()
    let hit_str = split('def class if else elif for', ' ')

    let res = []
    let tablevel = match(getline('.'), '[a-zA-Z0-9]')
    let clnnr = line('.')
    for lnnr in range(clnnr)
        let ln = getline(clnnr-lnnr-1)
        let tmp_tablevel = match(ln, "[a-zA-Z0-9'\"#]")
        " echo tmp_tablevel . '-' . tablevel
        if tmp_tablevel < tablevel
            for hs in hit_str
                let match_level = match(ln, '\<'.hs.'\>')
                if (match_level != -1) && (match_level == tmp_tablevel)
                    " echo ln
                    let res += [ln]
                    if match('elif else', '\<'.hs.'\>') == -1
                        let tablevel = tmp_tablevel
                    endif
                endif
            endfor
        endif
    endfor

    let L = len(res)
    for i in range(L)
        echo res[L-i-1]
    endfor
endfunction

function! <SID>chk_current_position()
    if &filetype == 'python'
        call <SID>chk_current_position_python()
    endif
endfunction

command! CCP call <SID>chk_current_position()
nnoremap <silent> <leader>c :CCP<CR>
" }}}

" ファイル内の特定のkeywordを探してlistする {{{
function! s:show_table_of_contents()
    if &filetype == 'toml'
        let tables = {
                    \ 'plugins': '^repo',
                    \ }
    elseif &filetype == 'python'
        let tables = {
                    \ 'functions': '^\s*def',
                    \ 'classes': '^\s*class',
                    \ }
    elseif &filetype == 'sshconfig'
        let tables = {
                    \ 'Hosts': '^Host\>',
                    \ }
    elseif &filetype == 'bib'
        let tables = {
                    \ 'articles' : '^@article',
                    \ }
    else
        let tables = {}
    endif
    if exists('g:ToC_add_tables')
        for k in keys(g:ToC_add_tables)
            let tables[k] = g:ToC_add_tables[k]
        endfor
    endif

    if len(tables) == 0
        return
    endif

    let res_table = {}
    let res_table['filename'] = expand('%') " (for jumping, future plan?)
    for k in keys(tables)
        let tmp_res = []
        for lnum in range(1, line('$'))
            let l_str = getline(lnum)
            if match(l_str, tables[k]) != -1
                let tmp_res = add(tmp_res, "\t".l_str.' @ '.lnum)
            endif
        endfor
        let res_table[k] = tmp_res
    endfor

    pclose
    silent 10split Table_of_Contents
    0,$delete _
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    setlocal nowrap
    setlocal nobuflisted
    setlocal previewwindow
    setlocal nofoldenable
    setlocal foldmethod=indent
    setlocal foldenable

    for k in keys(res_table)
        if k == 'filename'
            continue
        endif
        if len(res_table[k]) == 0
            continue
        endif
        execute "syntax keyword ToCkeys ".k
        call append(line('$'), k)
        call append(line('$'), res_table[k])
    endfor
    0delete _
    0   " move to top
    normal! zR

    " map test
    nnoremap <silent> <buffer> <expr> <CR> <SID>jump_line().'<CR>'
    wincmd p
endfunction

function! <SID>jump_line()
    let line = getline('.')
    let idx = strridx(line, '@')
    if idx == -1
        return ''
    endif
    let lnum = line[idx+2:]
    let ret = ':wincmd p | '.lnum
    return ret
endfunction
command! ShowTableOfContents call s:show_table_of_contents()
" }}}

