scriptencoding utf-8

" refer RGB -> YUV conversion equation
let s:w_r = 0.299 " <- 1.0
let s:w_g = 0.587 " <- 2.0
let s:w_b = 0.114 " <- 1.0
let s:thsd = 0.42
function! meflib#color#isdark(r, g, b, thsd=v:null, verbose=v:false)
    " 0 <= r, g, b <= 1
    if a:thsd is v:null
        let thsd = s:thsd
    else
        let thsd = a:thsd
    endif
    let val = (a:r*s:w_r+a:g*s:w_g+a:b*s:w_b)/(s:w_r+s:w_g+s:w_b)
    let cond = val < thsd
    if a:verbose
        echo printf("%.3f < %.2f", val, thsd)
    endif
    return cond
endfunction

function! meflib#color#get_colorid(r, g, b, gui)
    " 0 <= r, g, b <= 5
    if a:gui
        let gui_r = a:r==0 ? 0 : 55+40*a:r
        let gui_g = a:g==0 ? 0 : 55+40*a:g
        let gui_b = a:b==0 ? 0 : 55+40*a:b
        return '#' . printf('%02x', gui_r) . printf('%02x', gui_g) . printf('%02x', gui_b)
    else
        return (36*a:r)+(6*a:g)+a:b + 16
    endif
endfunction

function! meflib#color#get_today_rgb() abort
    let month = str2nr(strftime("%m"))
    let day = str2nr(strftime("%d"))
    let dow = str2nr(strftime("%w"))
    let r = (dow==6 ? 0 : dow)       " 土日は0
    let g = (month+(day-1)/10-1)%6   " 月+(日-1)の十の位で計算
    let b = abs((day+5-1)%10-5)      " 0 1 2 3 4 5 4 3 2 1 0 ...
    return [month, day, dow, r, g, b]
endfunction

function! meflib#color#chk_isdark(thsd=v:null) abort
    if has('gui_running') || &termguicolors
        let gui = 1
        let term = 'gui'
    else
        let gui = 0
        let term = 'cterm'
    endif

    echo "\n"
    for g in range(6)
        for r in range(6)
            for b in range(6)
                let i = 36*r+6*g+b+16
                if meflib#color#isdark(r/5.0, g/5.0, b/5.0, a:thsd)
                    let fg = gui ? '#ffffff' : '255'
                else
                    let fg = gui ? '#000000' : '234'
                endif
                let bg = meflib#color#get_colorid(r, g, b, gui)
                " echo printf('highlight tmpHl%d %sfg=%s %sbg=%s', i, term, fg, term, bg)
                execute printf('highlight tmpHl%d %sfg=%s %sbg=%s', i, term, fg, term, bg)
                execute 'echohl tmpHl'..i
                echon printf('%02x', i)
            endfor
            echohl None
            echon ' '
        endfor
        echo ''
    endfor
    echohl None
    echo ''
endfunction

function! meflib#color#ShowStatusLineBG() abort
    let [month, day, dow, stl_br, stl_bg, stl_bb] = meflib#color#get_today_rgb()
    let birthday = meflib#get('birthday', [0,0])
    if (month == birthday[0]) && (day == birthday[1])
        echo 'birthday!!'
        return
    endif
    let is_gui = has('gui_running') || (has('termguicolors') && &termguicolors)
    let echo_str  = 'red:'.stl_br
    let echo_str .= ' green:'.stl_bg
    let echo_str .= ' blue:'.stl_bb
    let echo_str .= ' => bg:'.meflib#color#get_colorid(stl_br, stl_bg, stl_bb, is_gui)
    let echo_str .= '   is_dark:'
    let echo_str .= printf('(%d*%.1f+%d*%.1f+%d*%.1f)/(%.1f+%.1f+%.1f)',
                \ stl_br, s:w_r, stl_bg, s:w_g, stl_bb, s:w_b,
                \ s:w_r, s:w_g, s:w_b)
    let echo_str .= printf(' = %.3f', (stl_br*s:w_r+stl_bg*s:w_g+stl_bb*s:w_b)/(s:w_r+s:w_g+s:w_b))
    let echo_str .= printf(' < %.3f', s:thsd*5)
    echo echo_str
endfunction

