"vim script encoding setting
scriptencoding utf-8

let s:pop_index = 0
let s:pop_ids = []

function! s:convert_config(config, str_list) abort
    " {{{ config list (not completed)
    " popid < 0; create new popup window, >= 0; update contents
    " bufid < 0; create new buffer, >= 0; use this buffer.
    " NOTE: currently this function is not aim to display normal buffer.
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
    "  <= win_enter
    " }}}

    if has('popupwin')
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
            elseif a:config.relative == 'editor'
                " need to do nothing.
            else
                echohl ErrorMsg
                echo "incorrect setting of relative: ".a:config.relative
                echohl None
            endif
        endif
    elseif has('nvim')
        if !has_key(a:config, 'relative') || !has_key(a:config, 'line') || !has_key(a:config, 'col')
            echo "'relative', 'line' and 'col' are required"
            return {}
        endif
        let v_config = {
                    \ 'relative': a:config['relative'],
                    \ 'row': a:config['line'],
                    \ 'col': a:config['col'],
                    \ 'style': 'minimal',
                    \ }

        if has_key(a:config, 'maxwidth')
            let v_config['width'] = a:config['maxwidth']
        else
            if empty(a:str_list)
                echo 'maxwidth is required when str_list is empty.'
                return {}
            endif
            let width = 1
            for st in a:str_list
                if len(st) > width
                    let width = len(st)
                endif
            endfor
            let v_config['width'] = width
        endif
        if has_key(a:config, 'maxheight')
            let v_config['height'] = a:config['maxheight']
        else
            if empty(a:str_list)
                echo 'maxheight is required when str_list is empty.'
                return {}
            endif
            let v_config['height'] = len(a:str_list)
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
            let v_config['anchor'] = anc
        endif
        if has_key(a:config, 'nv_border')
            let v_config['border'] = a:config['nv_border']
        endif
    endif
    return v_config
endfunction

function! meflib#floating#open(bufid, popid, str_list, config) abort
    let bufid = -1
    let popid = -1

    if has('popupwin')
        let v_config = s:convert_config(a:config, a:str_list)
        if empty(v_config)
            return [-1, -1]
        endif
        if a:bufid < 0
            let bufid = bufadd('[meflib_float_'..s:pop_index..']')
            call setbufvar(bufid, '&swapfile', 0)
            call setbufvar(bufid, '&backup', 0)
            call setbufvar(bufid, '&undofile', 0)
            call setbufvar(bufid, '&buftype', 'nofile')
            call setbufvar(bufid, '&bufhidden', 'hide')
            call setbufvar(bufid, '&buflisted', 0)
            call setbufvar(bufid, '&undolevels', -1)
            let s:pop_index += 1
        else
            let bufid = a:bufid
        endif
        if a:popid < 0
            let popid = popup_create(bufid, v_config)
            call add(s:pop_ids, popid)
        else
            let popid = a:popid
            call popup_setoptions(popid, v_config)
        endif
        if !empty(a:str_list)
            call popup_settext(popid, a:str_list)
        endif

    elseif has('nvim')
        let nv_config = s:convert_config(a:config, a:str_list)
        if empty(nv_config)
            return [-1, -1]
        endif
        if has_key(a:config, 'win_enter')
            if a:config['win_enter']
                let win_enter = v:true
            else
                let win_enter = v:false
            endif
        else
            let win_enter = v:false
        endif
        if empty(getbufinfo(a:bufid))
            let bufid = nvim_create_buf(v:false, v:true)
        else
            let bufid = a:bufid
        endif
        if !empty(a:str_list)
            " 詳細は分かっていないがscratch bufferがnomidifiableに
            " なっていることがあるのでfail safe
            call setbufvar(bufid, "&modifiable", v:true)
            call nvim_buf_set_lines(bufid, 0, -1, 0, a:str_list)
        endif
        if a:popid < 0
            let popid = nvim_open_win(bufid, win_enter, nv_config)
            call add(s:pop_ids, popid)
        else
            let popid = a:popid
            call nvim_win_set_config(popid, nv_config)
        endif
        if has_key(a:config, 'highlight')
            call win_execute(popid, printf(
                        \ "setlocal winhighlight=Normal:%s,Search:%s",
                        \ a:config['highlight'], a:config['highlight']))
        else
            call win_execute(popid, "setlocal winhighlight=Search:Normal")
        endif
    endif

    return [bufid, popid]
endfunction

function! meflib#floating#close(popids) abort
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

function! meflib#floating#close_all() abort
    call meflib#floating#close(s:pop_ids)
    let s:pop_ids = []
endfunction

let s:select_bid = -1
function! meflib#floating#select(str_list, config, callback) abort
    if has('popupwin')
        let v_config = s:convert_config(a:config, a:str_list)
        if empty(v_config)
            return -1
        endif
        let v_config['callback'] = a:callback
        call popup_menu(a:str_list, v_config)
    elseif has('nvim')
        let nv_config = s:convert_config(a:config, a:str_list)
        if empty(nv_config)
            return -1
        endif
        if s:select_bid < 0
            let s:select_bid = nvim_create_buf(v:false, v:true)
        endif
        call nvim_buf_set_lines(s:select_bid, 0, -1, 0, a:str_list)
        let wid = nvim_open_win(s:select_bid, v:false, nv_config)
        call win_execute(wid, 'setlocal cursorline')
        call win_execute(wid, 'setlocal nowrap')
        call win_execute(wid, 'setlocal nofoldenable')
        call win_execute(wid, 'setlocal winhighlight=CursorLine:PmenuSel')
        call win_execute(wid, 'normal! gg')
        while 1
            redraw
            try
                let key = getcharstr()
            catch /^Vim:Interrupt$/
                " ctrl-c (interrupt)
                call nvim_win_close(wid, v:false)
                call call(a:callback, [wid, -1])
                break
            endtry
            if key == "j" || key == "\<Down>"
                call win_execute(wid, 'normal! j')
            elseif key == "k" || key == "\<Up>"
                call win_execute(wid, 'normal! k')
            elseif key == "\<Enter>" || key == "\<Space>"
                let ln = line('.', wid)
                call nvim_win_close(wid, v:false)
                call call(a:callback, [wid, ln])
                break
            elseif key == "\<esc>" || key == 'x'
                call nvim_win_close(wid, v:false)
                call call(a:callback, [wid, -1])
                break
            endif
        endwhile
    endif
endfunction

