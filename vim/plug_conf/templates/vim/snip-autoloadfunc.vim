function! {{_expr_:expand('%:p:r')[strridx(expand('%:p:r'), 'autoload')+9:]->substitute('\(/\|\\\)', '#', 'g')}}#{{_cursor_}}()
endfunction

