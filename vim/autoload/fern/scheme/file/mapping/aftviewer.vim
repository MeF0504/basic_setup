
let s:fern_aft_conf = meflib#get('fern_aft_conf', {})
if !has_key(s:fern_aft_conf, 'cmd')
    let s:fern_aft_conf['cmd'] = 'aftviewer'
endif
if !has_key(s:fern_aft_conf, 'type_conf')
    let s:fern_aft_conf['type_conf'] = {
                \ 'ipynb': '-iv None -v',
                \ 'tgz': '-c',
                \ 'zip': '-c',
                \ }
endif

function! fern#scheme#file#mapping#aftviewer#init(disable_default_mappings) abort
    nnoremap <buffer><silent> <Plug>(fern-action-aftviewer) <Cmd>call <SID>call('aftviewer')<CR>
    nnoremap <buffer><silent> <Plug>(fern-action-0) <Cmd>echo "action canceled."<CR>
endfunction

function! s:call(name, ...) abort
  return call(
        \ 'fern#mapping#call',
        \ [funcref(printf('s:map_%s', a:name))] + a:000,
        \)
endfunction

function! s:map_aftviewer(helper) abort
    if !(has('terminal') || has('nvim'))
        echomsg 'terminal is not supported.'
        return
    endif
    if exists(':Terminal') != 2
        echomsg 'Terminal command is not found.'
        return
    endif
    if !executable(s:fern_aft_conf.cmd)
        echomsg 'aftviewer is not executable'
        return
    endif

    let path = a:helper.sync.get_cursor_node()._path
    let ext = fnamemodify(path, ':e')
    echomsg ext
    if has_key(s:fern_aft_conf.type_conf, ext)
        let opt = s:fern_aft_conf.type_conf[ext]
    else
        let opt = ''
    endif
    execute printf('Terminal %s %s %s', s:fern_aft_conf.cmd, path, opt)
endfunction

