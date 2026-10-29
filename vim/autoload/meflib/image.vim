scriptencoding utf-8

py3file <sfile>:h/image_conv.py

function! s:show_image_vim(file, height) abort
    python3 convert_image(vim.eval('a:file'), vim.eval('a:height'))
    let im_config = #{data: meflib#image#data->list2blob(),
                \ height: meflib#image#h,
                \ width: meflib#image#w,
                \ }
    let popup_option = {
                \ 'drag': v:false,
                \ 'dragall': v:false,
                \ 'resize': v:false,
                \ 'close': 'click',
                \ 'scrollbar': v:false,
                \ 'pos': "center",
                \ 'tabpage': -1,
                \ 'image': im_config,
                \ }
    let pid = popup_create("", popup_option)
    echo "click to close"
endfunction

function! s:show_image_nvim(file, height) abort
    python3 get_image_info(vim.eval('a:file'), vim.eval('a:height'))
    let h = meflib#image#h
    let w = meflib#image#w
    call v:lua.require'showim'.show(a:file, h, w)
endfunction

function! meflib#image#main(file) abort
    " DOC OPTIONS image_height
    " set the height (pixel) shown in popup/floating window
    " DOCEND
    " これ以上大きいと時間がかかりそう
    if has('popupwin') && has('image')
        let height = meflib#get('image_height', 128)
        call s:show_image_vim(a:file, height)
    elseif has('nvim') && luaeval('vim.ui ~= nil and vim.ui.img ~= nil')
        let height = meflib#get('image_height', 20)
        call s:show_image_nvim(a:file, height)
    else
        echo "popup/floating image is not supported."
    endif
endfunction

function! meflib#image#close() abort
    if !has('nvim')
        echo "nothing todo."
        return
    endif
    call v:lua.require'showim'.close()
endfunction
