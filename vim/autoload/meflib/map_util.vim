scriptencoding utf-8

let s:map_desc = {}

" map の説明追加
" " DOC FUNCTIONS meflib#map_util#desc()
" meflib#map_util#desc(mode, key, description)
" 
"Add the description of "mapleader"-linked maps.
" DOCEND
function! meflib#map_util#desc(mode, key, description) abort
    let s:map_desc[a:mode..'-'..a:key] = a:description
endfunction

" DOC FUNCTIONS meflib#map_util#show_maps()
" meflib#map_util#show_maps()
" 
"Show the list of "mapleader"-linked maps.
" DOCEND
function! meflib#map_util#show_maps()
    let leader = g:mapleader
    if leader == ' '
        let leader = '<space>'
    endif
    for m in maplist()
        if m['lhs'] =~ leader
            let desc = get(s:map_desc, m['mode']..'-'..m['lhs'][len(leader):], '')
            if empty(desc)
                let desc = m['rhs']
            endif
            echo printf('%s %s: %s', m.mode, m.lhs, desc)
        endif
    endfor
endfunction

 " multi-mapping(?)用
 " DOC FUNCTIONS meflib#map_util#multimap()
 " meflib#map_util#multimap({name})
 " 
 " Execute the mapping of {name} registered in |meflib-map_cmds|.
 " DOCEND
 function! meflib#map_util#multimap(name) abort
    let map_cmds = meflib#get('map_cmds', {})
    if empty(map_cmds)
        echo 'no maps registered.'
        return
    endif
    if !has_key(map_cmds, a:name)
        echo printf('incorrect map name: "%s"', a:name)
        return
    endif
    let cmds = map_cmds[a:name]
    if empty(cmds)
        echo printf('no maps in "%s".', a:name)
        return
    endif

    if len(cmds) == 1
        let cmd = values(cmds)[0]
        execute cmd
        return
    endif

    let old_cmdheight = &cmdheight
    let &cmdheight = len(cmds)+1
    echo map(deepcopy(cmds),
                \ {key, val -> key..': '..val})->values()->join("\n").."\n"
    " let key = input('key: ')
    let key = getcharstr()
    let &cmdheight = old_cmdheight
    normal! :
    if has_key(cmds, key)
        execute cmds[key]
    endif
endfunction
