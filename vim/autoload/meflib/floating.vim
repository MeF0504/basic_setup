"vim script encoding setting
scriptencoding utf-8

let s:pop_index = 0
let s:pop_ids = []
function! meflib#floating#open(bufid, popid, str_list, config) abort
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

    let bufid = -1
    let popid = -1

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
            endif
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
            if empty(a:str_list)
                echo 'maxwidth is required when str_list is empty.'
                return [-1, -1]
            endif
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
            if empty(a:str_list)
                echo 'maxheight is required when str_list is empty.'
                return [-1, -1]
            endif
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
        if has_key(a:config, 'win_enter')
            if a:config['win_enter']
                let win_enter = v:true
            else
                let win_enter = v:false
            endif
        else
            let win_enter = v:false
        endif
        if has_key(a:config, 'nv_border')
            let nv_config['border'] = a:config['nv_border']
        endif

        if empty(getbufinfo(a:bufid))
            let bufid = nvim_create_buf(v:false, v:true)
        else
            let bufid = a:bufid
        endif
        if !empty(a:str_list)
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
endfunction

