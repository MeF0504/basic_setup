" vimでLSP (Language Server Protocol)を扱うためのplugin
PlugWrapper 'prabirshrestha/vim-lsp', PlugCond(0, {})
call meflib#add('lazy_plugins', 'vim-lsp')

" config {{{
" lazy load
let g:lsp_auto_enable = 0
" https://qiita.com/kitagry/items/216c2cf0066ff046d200
" doc diagは欲しいので，とりあえずsignだけ有効にしてみる。
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_diagnostics_signs_enabled = 1
let g:lsp_diagnostics_signs_insert_mode_enabled = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
" cursor上にwarningとかあったら(echo|float表示)してくれる
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_float_cursor = 0 " disgnosticsのfloatは挙動が難しい..
let g:lsp_diagnostics_float_delay = 1500
" highlightはvim-cursorwordで表示しているので使わない
let g:lsp_document_highlight_enabled = 0
" LspPeekDefinition で表示する位置
let g:lsp_peek_alignment = 'top'
" 文字入力中にhelpを非表示（なんか不安定なため）
let g:lsp_signature_help_enabled = 0
" cとかjsでcode actionを無効化
let g:lsp_document_code_action_signs_enabled = 0
" clangdで設定を読むようにする
if executable('clangd')
    let g:lsp_setting = {
                \ 'clangd': {
                    \ 'cmd': ['clangd', '--enable-config'],
                    \ },
                \ }
endif
" Nerd font ならwarningとかも変えようか
if meflib#get('plug_opt', 'nerdfont', 0)
    let g:lsp_diagnostics_signs_warning = {'text': nr2char(0xf071)}
    let g:lsp_diagnostics_signs_error = {'text': nr2char(0xf068c)}
    let g:lsp_diagnostics_signs_hint = {'text': nr2char(0xf12a)}
    let s:lsp_status_icon = {
                \ 'running': nr2char(0xf05d)..' ',
                \ 'unknown server': nr2char(0xf059)..' ',
                \ 'exited': nr2char(0xf0a48)..' ',
                \ 'starting': nr2char(0xf01b)..' ',
                \ 'failed': nr2char(0xf46e)..' ',
                \ 'not running': nr2char(0xf057)..' ',
                \ }
    function! LspStatusIcon() abort
        for [stat, icon] in items(s:lsp_status_icon)
            echo printf('%s: %s', stat, icon)
        endfor
    endfunction
endif
" }}}
" highlights {{{
function! <SID>lsp_his() abort
    highlight default Lsp_Running ctermfg=233 ctermbg=183 guifg=#000000 guibg=#c8a0ef
    highlight default Lsp_NotRunning ctermfg=255 ctermbg=52 guifg=#eeeeee guibg=#702030
    highlight default Lsp_ErrorST cterm=BOLD ctermfg=7 ctermbg=1 gui=BOLD guifg=#eeeeee guibg=#d05050
    if meflib#get('plug_opt', 'nerdfont', 0)
        " copy highlight of SignColumn
        let [ctermbg, guibg] = meflib#basic#get_hi_info('SignColumn', ['ctermbg', 'guibg'])
        if &background == 'dark'
            let cwarn = "226"
            let gwarn = "#f0f000"
            let cerr = "124"
            let gerr = "#d00000"
            let chint = "253"
            let ghint = "#d5d5d5"
        else
            let cwarn = "136"
            let gwarn = "#b0a000"
            let cerr = "124"
            let gerr = "#d00000"
            let chint = "235"
            let ghint = "#2f2f2f"
        endif
        execute printf("highlight default LspWarningText ctermfg=%s ctermbg=%s guifg=%s guibg=%s", cwarn, ctermbg, gwarn, guibg)
        execute printf("highlight default LspErrorText ctermfg=%s ctermbg=%s guifg=%s guibg=%s", cerr, ctermbg, gerr, guibg)
        execute printf("highlight default LspHintText ctermfg=%s ctermbg=%s guifg=%s guibg=%s", chint, ctermbg, ghint, guibg)
    endif
endfunction
" call meflib#add('plugin_his', expand('<SID>').'lsp_his')
" ↑ だとseiyaより後に呼ばれて一部透過しないので，↓で呼ぶ
autocmd PlugLocal User vim-lsp call s:lsp_his()
" が，color scheme を変えるとhighlightが消えるので，後から追加する
autocmd PlugLocal User vim-lsp call meflib#add('plugin_his', expand('<SID>').'lsp_his')
" }}}
" reference: lsp_settings#profile#status()
function! <SID>chk_lsp_running(bool, echo) abort " {{{
    let active_servers = lsp#get_allowed_servers()
    if empty(active_servers)
        if a:echo
            echomsg 'No Language server'
            sleep 300ms
        endif
        if a:bool
            return v:false
        else
            return 'No LSP'
        endif
    endif
    for active_server in active_servers
        let lsp_status = lsp#get_server_status(active_server)
        if lsp_status == 'running'
            if a:bool
                return v:true
            else
                if meflib#get('plug_opt', 'nerdfont', 0)
                    let lsp_status = s:lsp_status_icon[lsp_status]
                endif
                return printf('%s:%s', active_server, lsp_status)
            endif
        endif
    endfor
    if a:bool
        return v:false
    else
        if meflib#get('plug_opt', 'nerdfont', 0)
            let lsp_status = s:lsp_status_icon[lsp_status]
        endif
        return printf('%s:%s', active_server, lsp_status)
    endif
endfunction
" }}}
function! s:show_lsp_server_status(tid) abort " {{{
    let lsp_status = <SID>chk_lsp_running(0, 0)
    if has('nvim')
        let line = 1
    else
        let line = 2
    endif
    if lsp_status[match(lsp_status, ':')+1:] == 'running'
        let highlight = 'LSP_Running'
    else
        let highlight = 'Lsp_NotRunning'
    endif
    let config = {
                \ 'relative': 'editor',
                \ 'line': line,
                \ 'col': &columns,
                \ 'pos': 'topright',
                \ 'highlight': highlight,
                \ }
    let [s:lsp_bufid, s:lsp_popid] = meflib#floating#open(s:lsp_bufid, s:lsp_popid, [lsp_status], config)
endfunction
let s:lsp_popid = -1
let s:lsp_bufid = -1
" }}}
function! <SID>lsp_status_tab() abort " {{{
    let name_max = 8
    let lsp_status = <SID>chk_lsp_running(0, 0)
    let idx = strridx(lsp_status, ':')
    if idx == -1
        let name = lsp_status
        let status = ''
        let highlight = 'Lsp_NotRunning'
    else
        let name = lsp_status[:idx-1]
        if len(name) > name_max
            let name = name[:name_max-1]
        endif
        if meflib#get('plug_opt', 'nerdfont', 0)
            let is_running = s:lsp_status_icon['running']
        else
            let is_running = 'running'
        endif
        let status = lsp_status[idx+1:]
        if status == is_running
            let highlight = 'LSP_Running'
        else
            let highlight = 'Lsp_NotRunning'
        endif
    endif
    let footer = printf('%%#%s#|%s:%s%%#%s#', highlight, name, status, 'TabLineFill')
    " lenだとnerdfontの長さを誤るのでstrchars。
    let len = strchars(name..':'..status)+1
    return [footer, len]
endfunction
" }}}
" lsp server が動いていれば<c-]>で定義に飛んで，<c-j>でreferencesを開く
" <c-p>でhelp hover, definition, type definition を選択
let s:tag_maps = [
            \ maparg("\<c-]>", 'n', 0, 1),
            \ maparg("\<c-j>", 'n', 0, 1),
            \ maparg("\<c-p>", 'n', 0, 1),
            \ ]
function! s:lsp_mapping(map) abort " {{{
    if !s:chk_lsp_running(1, 1)
        " not running
        let mapargs = s:tag_maps[a:map-1]
        if mapargs.expr
            let tmp = substitute(mapargs.rhs, '<SID>', printf('<SNR>%d_', mapargs.sid), '')
            return eval(tmp)
        else
            " ↓ doesn't work?
            " let tmp = substitute(mapargs.rhs, '<', '\\<', 'g')
            " return tmp
            if a:map == 2
                return "\<Cmd>Gregrep ex=None dir=opened\<CR>"
            elseif a:map == 3
                return "\<Cmd>ptjump "..expand('<cword>').."\<CR>"
            endif
        endif
    endif
    if a:map == 1
        " <c-]>
        echo 'LSP def; [t]ab/[s]plit/[v]ertical/cur_win<CR> '
        let yn = getcharstr()
        if yn == 't'
            return "\<Cmd>tab LspDefinition\<CR>"
        elseif yn == 's'
            return "\<Cmd>aboveleft LspDefinition\<CR>"
        elseif yn == 'v'
            return "\<Cmd>vertical LspDefinition\<CR>"
        elseif yn == "\<CR>"
            return "\<Plug>(lsp-definition)"
        else
            echo 'canceled'
            return ''
        endif
    elseif a:map == 2
        " <c-j>
        return "\<Plug>(lsp-references)"
    elseif a:map == 3
        " <c-p>
        let res = ""
        let old_cmdheight = &cmdheight
        let &cmdheight = 5
        echo  " 1: help (float)\n"..
            \ " 2: definition\n"..
            \ " 3: type definition\n"..
            \ " 4: help (preview): "
        let num = getcharstr()
        if num == '1'
            let res = "\<Cmd>LspHover --ui=float\<CR>"
        elseif num == '2'
            let res = "\<Plug>(lsp-peek-definition)"
        elseif num == '3'
            let res = "\<Plug>(lsp-peek-type-definition)"
        elseif num == '4'
            let res = "\<Cmd>LspHover --ui=preview\<CR>"
        endif
        let &cmdheight = old_cmdheight
        redraw!
        if empty(res)
            echo 'canceled'
        endif
        return res
    endif
endfunction
" }}}
function! s:lsp_move_map(map, motion) abort " {{{
    if !g:lsp_diagnostics_float_cursor
        return a:motion
    elseif lsp#document_hover_preview_winid() != v:null
        " check lsp-hover exists.
        return a:motion
    else
        return a:map
    endif
endfunction " }}}
function! s:lsp_unmap(map) abort " {{{
    let map_dict = maparg(a:map, 'n', 0, 1)
    if !empty(map_dict) && map_dict.buffer
        execute "nunmap <buffer>"..a:map
    endif
endfunction " }}}
function! s:vim_lsp_hook() abort
    if !exists('g:lsp_loaded')
        return
    endif
    call lsp#enable()
    " mapping {{{
    nmap <expr> <c-]> <SID>lsp_mapping(1)
    nmap <silent> <expr> <c-j> <SID>lsp_mapping(2)
    nmap <silent> <expr> <c-p> <SID>lsp_mapping(3)
    nnoremap <leader>d <Cmd>LspDocumentDiagnostics<CR>
    call meflib#map_util#desc('n', 'd', 'LspDocumentDiagnostics')
    " help file でバグる？
    autocmd PlugLocal FileType help nnoremap <buffer> <c-]> <c-]>
    " }}}
    " autocmd {{{
    " normal modeでmouseが使えないとscroll出来ないので，とりあえず対処。
    " lsp_float_closed がvimだとpopupがcursor moveで閉じても叩かれない？ので，qで閉じるようにする
    autocmd PlugLocal User lsp_float_opened
                \ nnoremap <buffer> <expr> <c-d>
                \ <SID>lsp_move_map("<c-d>", lsp#scroll(+5))
    autocmd PlugLocal User lsp_float_opened
                \ nnoremap <buffer> <expr> <c-u>
                \ <SID>lsp_move_map("<c-u>", lsp#scroll(-5))
    autocmd PlugLocal User lsp_float_opened
                \ nnoremap <buffer> <expr> <c-e>
                \ <SID>lsp_move_map("<c-e>", lsp#scroll(+1))
    autocmd PlugLocal User lsp_float_opened
                \ nnoremap <buffer> <expr> <c-y>
                \ <SID>lsp_move_map("<c-y>", lsp#scroll(-1))
    autocmd PlugLocal User lsp_float_opened
                \ nmap <buffer> <silent> q <Plug>(lsp-preview-close)
    autocmd PlugLocal User lsp_float_closed call s:lsp_unmap("<c-d>")
    autocmd PlugLocal User lsp_float_closed call s:lsp_unmap("<c-u>")
    autocmd PlugLocal User lsp_float_closed call s:lsp_unmap("<c-e>")
    autocmd PlugLocal User lsp_float_closed call s:lsp_unmap("<c-y>")
    autocmd PlugLocal User lsp_float_closed call s:lsp_unmap("q")
    autocmd PlugLocal BufEnter LspHoverPreview setlocal nolist
    autocmd PlugLocal WinEnter * if <SID>chk_lsp_running(1, 0) |
                \ setlocal keywordprg=:LspHover\ --ui=preview | endif
    " }}}
    " show status {{{
    " call timer_start(1000, s:sid.'show_lsp_server_status', {'repeat':-1})
    " autocmd PlugLocal WinLeave * call meflib#floating#close(s:lsp_popid) | let s:lsp_popid = -1
    call meflib#add('tabline_footer', expand('<SID>').'lsp_status_tab')
    let lsp_sl = "%#Lsp_ErrorST#%{lsp#get_buffer_first_error_line()==v:null?'':' ! '}%#StatusLine#"
    let def_sl = meflib#get('def_statusline', '')
    let cur_sl = meflib#get('statusline', '_', def_sl)
    call meflib#set('statusline', '_', cur_sl..lsp_sl)
    " }}}
endfunction
autocmd PlugLocal User vim-lsp call s:vim_lsp_hook()
" autocmd PlugLocal VimEnter * call s:vim_lsp_hook()

" vim-lspの設定用plugin
PlugWrapper 'mattn/vim-lsp-settings', PlugCond(0, {})
call meflib#add('lazy_plugins', 'vim-lsp-settings')

