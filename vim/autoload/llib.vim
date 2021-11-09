"vim script encording setting
scriptencoding utf-8

" get vim config directory
function! llib#get_conf_dir()
    if has('nvim')
        if exists("$XDG_CONFIG_HOME")
            let vimdir = expand($XDG_CONFIG_HOME . "/nvim/")
        else
            let vimdir = expand('~/.config/nvim/')
        endif
    else
        if has('win32')
            let vimdir = expand('~/vimfiles/')
        else
            let vimdir = expand('~/.vim/')
        endif
    endif

    return vimdir
endfunction

function! llib#set_local_var(var_name, val)
    execute "let s:"..a:var_name.." = a:val"
endfunction

function! llib#get_local_var(var_name, default)
    if empty(a:var_name)
        for var in sort(keys(s:))
            echohl Identifier
            echo var..': '
            echohl None
            echon s:[var]
        endfor
    elseif exists("s:"..a:var_name)
        execute "return s:"..a:var_name
    else
        " execute "let s:"..a:var_name.." = a:default"
        return a:default
    endif
endfunction

" 関数の引数解析用関数 (key=arg)
function! llib#analythis_args_eq(arg) abort
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

" 関数の引数解析用関数 (-opt arg)
function! llib#analythis_args_hyp(args, args_config) abort
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

function! llib#popup_wrapper(bufid, popid, str_list, config)
    " popid < 0; create new popup window, >= 0; update contents
    " bufid is not required in Vim. 
    " (vim) config <=> nvim config
    " (line, col) <= relative
    " line => row
    " col => col
    " pos => anchor
    " posinvert
    " textprop
    " textpropwin
    " textpropid
    " fixed
    " flip
    " maxheight => height
    " minheight => --
    " maxwidth => width
    " minwidth => --
    " firstline
    " hidden
    " tabpage
    " title
    " wrap
    " drag
    " resize
    " close
    " highlight => (highlight)
    " padding
    " border
    " borderhighlight
    " borderchars
    " scrollbar
    " scrollbarhighlight
    " thumbhighlight
    " zindex => zindex
    " mask
    " time
    " moved
    " mousemoved
    " cursorline
    " filter
    " mapping
    " filtermode
    " callback

    let popid = -1

    if has('popupwin')
        let bufid = -1
        let v_config = deepcopy(a:config)

        if has_key(a:config, 'relative')
            unlet v_config['relative']
            if a:config.relative == 'cursor'
                if has_key(a:config, 'line') && line < 0
                    let v_config.line = 'cursor'.a:config.line
                elseif has_key(a:config, 'line') && line > 0
                    let v_config.line = 'cursor+'.a:config.line
                else
                    let v_config.line = 'cursor'
                endif
                if has_key(a:config, 'col') && col < 0
                    let v_config.col = 'cursor'.a:config.col
                elseif has_key(a:config, 'col') && col > 0
                    let v_config.col = 'cursor+'.a:config.col
                else
                    let v_config.col = 'cursor'
                endif
            elseif a:config.relative == 'win'
                let [hshift, wshift] = win_screenpos(0)
                let v_config.line = a:config.line+hshift-1
                let v_config.col = a:config.col+wshift-1
            endif
        endif
        if a:popid < 0
            let popid = popup_create(a:str_list, v_config)
        else
            let popid = a:popid
            call popup_setoptions(popid, v_config)
            call popup_settext(popid, a:str_list)
        endif

    elseif has('nvim')
        if !has_key(a:config, 'relative') || !has_key(a:config, 'line') || !has_key(a:config, 'col')
            echo "'relative', 'line' and 'col' are required"
            return [-1,-1]
        endif
        let nv_config = {
                    \ 'relative': a:config['relative'],
                    \ 'row': a:config['line'],
                    \ 'col': a:config['col'],
                    \ 'style': 'minimal',
                    \ }

        if has_key(a:config, 'maxwidth')
            let nv_config['width'] = a:config['maxwidth']
        else
            let width = 1
            for st in a:str_list
                if len(st) > width
                    let width = len(st)
                endif
            endfor
            let nv_config['width'] = width
        endif
        if has_key(a:config, 'maxheight')
            let nv_config['height'] = a:config['maxheight']
        else
            let nv_config['height'] = len(a:str_list)
        endif
        if has_key(a:config, 'pos')
            if a:config.pos == 'topleft'
                let anc = 'NW'
            elseif a:config.pos == 'topright'
                let anc = 'NE'
            elseif a:config.pos == 'botleft'
                let anc = 'SW'
            elseif a:config.pos == 'botright'
                let anc = 'SE'
            else
                " fail safe
                let anc = 'NW'
            endif
            let nv_config['anchor'] = anc
        endif

        if empty(getbufinfo(a:bufid))
            let bufid = nvim_create_buf(v:false, v:true)
        else
            let bufid = a:bufid
        endif
        call nvim_buf_set_lines(bufid, 0, -1, 0, a:str_list)
        if a:popid < 0
            let popid = nvim_open_win(bufid, v:false, nv_config)
        else
            let popid = a:popid
            call nvim_win_set_config(popid, nv_config)
        endif
        if has_key(a:config, 'highlight')
            call win_execute(popid, "set winhighlight=Normal:".a:config['highlight'])
        endif
    endif

    return [bufid, popid]
endfunction

function! llib#popup_close(popids)
    if type(a:popids) != type([])
        let popids = [a:popids]
    else
        let popids = a:popids
    endif
    for popid in popids
        if popid < 0
            continue
        endif
        if has('popupwin')
            if match(popup_list(), popid) != -1
                call popup_close(popid)
            endif
        elseif has('nvim')
            if (match(nvim_list_wins(),popid)!=-1) && !empty(nvim_win_get_config(popid)['relative'])
                call nvim_win_close(popid, v:false)
            endif
        endif
    endfor
endfunction

