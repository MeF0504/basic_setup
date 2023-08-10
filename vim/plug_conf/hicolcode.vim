" color codeに色を付ける
Plug 'MeF0504/hicolcode.vim', PlugCond(1, {'on': 'ColCode'})

function! s:bash_syntax(line, idx) abort
    let match_list = {
                \ '\\e\[30m': [0, 0, 0],
                \ '\\e\[31m': [150, 0, 0],
                \ '\\e\[32m': [0, 150, 0],
                \ '\\e\[33m': [150, 150, 0],
                \ '\\e\[34m': [0, 0, 150],
                \ '\\e\[35m': [150, 0, 150],
                \ '\\e\[36m': [0, 150, 150],
                \ '\\e\[37m': [200, 200, 200],
                \ '\\e\[40m': [0, 0, 0],
                \ '\\e\[41m': [150, 0, 0],
                \ '\\e\[42m': [0, 150, 0],
                \ '\\e\[43m': [150, 150, 0],
                \ '\\e\[44m': [0, 0, 150],
                \ '\\e\[45m': [150, 0, 150],
                \ '\\e\[46m': [0, 150, 150],
                \ '\\e\[47m': [200, 200, 200],
                \ '\\e\[90m': [150, 150, 150],
                \ '\\e\[91m': [255, 0, 0],
                \ '\\e\[92m': [0, 255, 0],
                \ '\\e\[93m': [255, 255, 0],
                \ '\\e\[94m': [0, 0, 255],
                \ '\\e\[95m': [255, 0, 255],
                \ '\\e\[96m': [0, 255, 255],
                \ '\\e\[97m': [255, 255, 255],
                \ '\\e\[100m': [150, 150, 150],
                \ '\\e\[101m': [255, 0, 0],
                \ '\\e\[102m': [0, 255, 0],
                \ '\\e\[103m': [255, 255, 0],
                \ '\\e\[104m': [0, 0, 255],
                \ '\\e\[105m': [255, 0, 255],
                \ '\\e\[106m': [0, 255, 255],
                \ '\\e\[107m': [255, 255, 255],
                \}
    for [ptrn, rgb] in items(match_list)
        if match(a:line, ptrn, a:idx) != -1
            return rgb+[ptrn]
        endif
    endfor
    return []
endfunction
function! s:vim_cterm_hi(line, idx) abort
    let num = str2nr(split(a:line[a:idx+8:])[0])
    let ptrn = 'cterm[fb]g=\zs'..num..'\ze\>'
    if num < 16
        let rgb = [
                    \ [0, 0, 0], [150, 0, 0], [0, 150, 0], [150, 150, 0],
                    \ [0, 0, 150], [0, 150, 150], [150, 0, 150], [200, 200, 200],
                    \ [150, 150, 150], [255, 0, 0], [0, 255, 0], [255, 255, 0],
                    \ [0, 0, 255], [0, 255, 255], [255, 0, 255], [255, 255, 255],
                    \ ]
        return rgb[num]+[ptrn]
    elseif num < 232
        let r = (num-16)/36
        let g = (num-16-r*36)/6
        let b = num-16-r*36-g*6
        let r = r == 0 ? 0 : 55+40*r
        let g = g == 0 ? 0 : 55+40*g
        let b = b == 0 ? 0 : 55+40*b
        return [r, g, b, ptrn]
    elseif num < 256
        let wb = 8+10*(num-232)
        return [wb, wb, wb, ptrn]
    else
        return []
    endif
endfunction

let g:hicolcode_config = get(g:, 'hicolcode_config', {})
let g:hicolcode_config.sh = [
            \ {
                \ 'ptrn': '\\e\[[0-9]\+m',
                \ 'func': expand('<SID>')..'bash_syntax',
                \}
            \]
let g:hicolcode_config.vim = [
            \ {
                \ 'ptrn': 'cterm[fb]g=[0-9]\+',
                \ 'func': expand('<SID>')..'vim_cterm_hi',
                \ }
                \ ]

