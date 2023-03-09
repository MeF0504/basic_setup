function! {{_expr_:expand('%:p:r')[strridx(expand('%:p:r'), 'autoload'):]->substitute('autoload/', '', '')->substitute('/', '#', 'g')}}#{{_cursor_}}()
endfunction

