scriptencoding utf-8

" terminal commandを快適に使えるようにする
"" http://koturn.hatenablog.com/entry/2018/02/12/140000
let s:term_cnt = 1
let s:term_opts = ['term']
function! meflib#terminal#comp(arglead, cmdline, cursorpos) abort
    ":h :command-completion-custom
    let opt_idx = strridx(a:cmdline, '-')
    let end_space_idx = strridx(a:cmdline, ' ')
    " return ['-1-'.a:arglead, '-2-'.a:cmdline, '-3-'.a:cursorpos, '-4-'.a:cmdline[opt_idx:]]
    if a:arglead[0] == '-'
        " select option
        return filter(map(copy(s:term_opts), '"-"..v:val'), '!stridx(tolower(v:val), a:arglead)')
    elseif a:cmdline[opt_idx:end_space_idx-1] == '-term'
        let term_list = meflib#terminal#term_list()
        let term_names = filter(map(term_list, 'bufname(v:val)'),
                    \ '!stridx(tolower(v:val), a:arglead)')
        return term_names
    else
        " shell コマンド一覧
        if empty(a:arglead)
            " 未入力だとちゃんと動かないので...
            return []
        endif
        let cmdlines = a:cmdline->split()
        let def_opts = ['Terminal']
        let def_opts += map(copy(s:term_opts), '"-"..v:val')
        if match(cmdlines, '-term') != -1
            " -termがあるならコマンドは取らない
            return []
        else
            for cmd in cmdlines[:-2]
                if match(def_opts, cmd) == -1
                    " shell command を入力済み
                    return getcompletion(a:arglead, 'file')
                endif
            endfor
        endif
        return getcompletion(a:arglead, 'shellcmd')
    endif
endfunction

function! s:open_term(bufname) abort
    let bufn = bufnr(a:bufname)
    if bufn == -1
        " throw 'E94: No matching buffer for ' . a:bufname
        echoerr 'No matching buffer for "' . a:bufname . '"'
        return 1        " 異常終了ということにしよう
    elseif exists('*term_list') && index(term_list(), bufn) == -1
        " throw a:bufname . 'is not a terminal buffer'
        echoerr '"' . a:bufname . '"is not a terminal buffer'
        return 1        " 異常終了ということにしよう
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
function! s:set_term_opt(is_float, name, finish) abort
    let term_opt = {}

    let env = {}
    if has('win32') || has('win64')
        " 日本語Windowsの場合`ja`が設定されるので、入力ロケールに合わせたUTF-8に設定しなおす
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

        if !has('nvim')
            call extend(term_opt, {
                        \ 'term_name': a:name.'_'.s:term_cnt,
                        \ 'cwd': $USERPROFILE,
                        \ })
            let s:term_cnt += 1
        endif
    endif
    if !has('nvim')
        if a:is_float
            call extend(term_opt, {
                        \ 'hidden': v:true,
                        \ 'curwin': v:false,
                        \ })
        else
            call extend(term_opt, {
                        \ 'curwin': v:true,
                        \ })
        endif
        call extend(term_opt, {
                    \ 'term_finish': a:finish,
                    \ 'term_name': a:name.'_'.s:term_cnt,
                    \ 'ansi_colors': meflib#terminal#get_term_color(),
                    \ })
        let s:term_cnt += 1
    endif

    let term_opt.env = env
    return term_opt
endfunction

function! s:open_term_win(opts)
    " term_startでgit for windowsのbashを実行する
    " DOC OPTIONS win_term_cmd
    " List of command and options to be used in Terminal in Windows OS.
    " DOCEND
    let cmd = a:opts
    if empty(cmd)
        let cmd = meflib#get('win_term_cmd', ['bash.exe', '-l'])
        let term_fin = 'close'
    else
        let term_fin = 'open'
    endif

    let term_opt = s:set_term_opt(0, '!'.cmd[0], term_fin)
    if has('nvim')
        call termopen(cmd, term_opt)
        startinsert
    else
        call term_start(cmd, term_opt)
    endif
endfunction

function! s:open_term_float(opts) abort
    let float_opt = {
                \ 'relative': 'win',
                \ 'line': &lines/2-&cmdheight-1,
                \ 'col': 5,
                \ 'maxheight': &lines/2-&cmdheight,
                \ 'maxwidth': &columns-10,
                \ 'win_enter': 1,
                \ 'border': [],
                \ 'nv_border': "rounded",
                \ 'minwidth': &columns-10,
                \ 'minheight': &lines/2-&cmdheight,
                \ }
    let cmd = a:opts
    if empty(cmd)
        if has('win32') || has('win64')
            let cmd = meflib#get('win_term_cmd', ['bash.exe', '-l'])
        else
            let cmd = [&shell]
        endif
        let term_finish = 'close'
    else
        let term_finish = 'open'
    endif

    let term_opt = s:set_term_opt(1, '!'.cmd[0], term_finish)

    if has('nvim')
        highlight TermNormal ctermbg=None guibg=None
        call extend(float_opt, {'highlight': 'TermNormal'}, 'force')
        let [bid, pid] = meflib#floating#open(-1, -1, [], float_opt)
        call termopen(cmd, term_opt)
        startinsert
    else
        let bid = term_start(cmd, term_opt)
        if bid == 0
            echohl ErrorMsg
            echo 'fail to open the terminal.'
            echohl None
            return
        endif
        call meflib#floating#open(bid, -1, [], float_opt)
        let s:term_cnt += 1
        return
    endif
endfunction

function! meflib#terminal#main(mod, ...) abort
    if !has('terminal') && !has('nvim')
        echoerr "this vim doesn't support terminal!!"
        return
    endif

    let args_config = {'term':1}
    if a:0 == 0
        let opts = ''
    else
        let opts = a:1
    endif
    let opts = meflib#basic#analysis_args_hyp(opts, args_config)
    if empty(opts)
        return
    endif

    " DOC OPTIONS term_default
    " Default command modifier for terminal.
    " DOCEND
    if empty(a:mod)
        let win_opt = meflib#get('term_default', 'tab')
    else
        let win_opt = a:mod
    endif

    let term_opt = ''
    if has('win32') || has('win64')
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
            execute printf('%s new', win_opt)
            call s:open_term_win(opts['no_opt'])
        endif

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
                execute printf('%s new', win_opt)
                let term_opt .= join(opts['no_opt'])
                execute 'terminal '.term_opt
                " rename buffer
                execute "silent file ".substitute(expand('%'), ' ', '', 'g')
                startinsert
            endif

        else
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
                execute printf('%s new', win_opt)
                if empty(opts['no_opt'])
                    let cmd = [&shell]
                    let term_finish = 'close'
                else
                    let cmd = opts['no_opt']
                    let term_finish = 'open'
                endif
                let term_opt = s:set_term_opt(0, '!'.cmd[0], term_finish)
                call term_start(cmd, term_opt)
                " rename buffer (no need?)
                " execute "silent file ".substitute(expand('%'), ' ', '', 'g')
            endif
        endif
    endif

    setlocal nolist
    setlocal foldcolumn=0
    setlocal nonumber
endfunction

" get term color for
function! meflib#terminal#get_term_color() abort
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

" terminal buffer 一覧
function! meflib#terminal#term_list() abort
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

" terminalの色設定
" DOC OPTIONS term_col_name
" terminal color name.
" DOCEND
function! meflib#terminal#set_term_color(col_name=v:null) abort
    if a:col_name != v:null
        call meflib#set('term_col_name', a:col_name)
    endif
    if has('nvim')
        let [
                    \ g:terminal_color_0,
                    \ g:terminal_color_1,
                    \ g:terminal_color_2,
                    \ g:terminal_color_3,
                    \ g:terminal_color_4,
                    \ g:terminal_color_5,
                    \ g:terminal_color_6,
                    \ g:terminal_color_7,
                    \ g:terminal_color_8,
                    \ g:terminal_color_9,
                    \ g:terminal_color_10,
                    \ g:terminal_color_11,
                    \ g:terminal_color_12,
                    \ g:terminal_color_13,
                    \ g:terminal_color_14,
                    \ g:terminal_color_15
                    \ ] = meflib#terminal#get_term_color()
    elseif has('terminal') && (has('patch-8.0.1685') || v:version>=801)
        let g:terminal_ansi_colors = meflib#terminal#get_term_color()
    endif
endfunction
call meflib#terminal#set_term_color()
