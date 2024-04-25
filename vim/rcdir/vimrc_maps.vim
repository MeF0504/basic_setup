" vim script encoding setting
scriptencoding utf-8
" vim map(key) settings

" 誤って使うとまずいkeymapを削除
function! s:close(key) abort
    " キーボード認識が狂うとEnterも入らないのでgetcharにする
    echo 'Are you really close file? (y/[n]): '
    let yn = getcharstr()
    if yn !=# 'y'
        echo "don't close"
        return
    endif
    if a:key ==# 'ZZ'
        xit
    elseif a:key ==# 'ZQ'
        quit!
    endif
endfunction
" 保存して終了 :h ZZ
nnoremap ZZ <Cmd>call <SID>close('ZZ')<CR>
" 保存せずに終了 :h ZQ
nnoremap ZQ <Cmd>call <SID>close('ZQ')<CR>
" ex modeに切り替え。viの前身か？ :h Q
nnoremap Q <Nop>
" current windowを閉じる :h CTRL-W_q
nnoremap <c-w>q <Nop>
" sをctrl-wにmapしているので...
nnoremap sq <Nop>
" ctrl-w cでもwindowを閉じるらしいな
nnoremap <c-w>c <Nop>
nnoremap sc <Nop>

" 使いやすいようにmapping
" window 移動
nnoremap s <c-w>
nnoremap sj <c-w>j
nnoremap s<Down> <c-w>j
nnoremap sk <c-w>k
nnoremap s<Up> <c-w>k
nnoremap sh <c-w>h
nnoremap s<Left> <c-w>h
nnoremap sl <c-w>l
nnoremap s<Right> <c-w>l

" new tab
nnoremap T :<c-u>tabnew<space>

" quick fix window
nnoremap <silent> co <Cmd>botright copen<CR>
nnoremap <silent> cc <Cmd>cclose<CR>
nnoremap <silent> cn <Cmd>cnewer<CR>
nnoremap <silent> cp <Cmd>colder<CR>

" search
nnoremap / /\v
function! s:star_map() abort
    if empty(expand('<cword>'))
        return "\<Cmd>echo 'empty'\<CR>"
    else
        return "/\\v\<\<c-r>\<c-w>\>\<CR>"
    endif
endfunction
nnoremap <expr> * <SID>star_map()

" tab 移動
nnoremap g<Right> gt
nnoremap g<Left> gT
nnoremap gl gt
nnoremap gh gT
" ↓ <num>gt に合わせて0gt
nnoremap <silent> 0gt <Cmd>tablast<CR>
nnoremap <silent> g> <Cmd>tabmove +1<CR>
nnoremap <silent> g< <Cmd>tabmove -1<CR>
nnoremap <silent> g$> <Cmd>tabmove $<CR>
nnoremap <silent> g0< <Cmd>tabmove 0<CR>

" 画面自体を左右に移動
nnoremap <expr> H winwidth('.')/3.'zh'
nnoremap <expr> L winwidth('.')/3.'zl'

" commandlineでも<c-a>で最初に戻りたい
cnoremap <c-a> <c-b>

" Yで行末までヤンク
nnoremap Y y$
vnoremap Y $y

" fold関連
" 大文字にするとファイル全体に適用
nnoremap zO zR
nnoremap zC zM
" 右方向で再帰的に開く
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zO' : 'l'
nnoremap <expr> <Right> foldclosed(line('.')) != -1 ? 'zO' : 'l'
" Enterで１段開いたり閉じたりする
nnoremap <expr> <CR> pumvisible() != 0 ? '<c-m>' :
            \ foldlevel('.') != 0 ? 'za' : '<CR>'

" 今の行を画面のtopにする。ctrl-lはterminalの感覚
nnoremap <c-l> z<CR>

" goto file をタブで開く
nnoremap gf <c-w>gf

" tag jump
" 候補が複数ある場合にリストを表示
" nnoremap <c-]> g<c-]>
function! s:tag_jump() abort
    echo 'tag jump; [t]ab/[s]plit/[v]ertical/cur_win<CR> '
    let yn = getcharstr()
    if yn == 't'
        return "\<Cmd>tab tjump "..expand('<cword>').."\<CR>"
    elseif yn == 's'
        return "\<Cmd>stjump "..expand('<cword>').."\<CR>"
    elseif yn == 'v'
        return "\<Cmd>vertical stjump "..expand('<cword>').."\<CR>"
    elseif yn == "\<CR>"
        return "g\<c-]>"
    else
        echo 'canceled'
        return ''
    endif
endfunction
" 更に改良，lspと同様に開き方を選択
nnoremap <expr> <c-]> <SID>tag_jump()
" 分割で表示
nnoremap <silent> g<c-]> <Cmd>vertical stjump<CR>
" preview で開く
nnoremap <silent> <c-p> <Cmd>execute "ptjump "..expand("<cword>")<CR>
" ファイル内で検索
if exists(":Gregrep") == 2
    nnoremap <silent> <c-j> <Cmd>Gregrep ex=None dir=opened<CR>
endif

" \で検索のハイライトを消す
nnoremap <silent> \ <Cmd>nohlsearch<CR>

" 1行複製をよく使うので...
nnoremap yp yyp
nnoremap yP yyP
nnoremap dp ddp
nnoremap dP ddkP

" preview , nofile, quickfix window, help windowはqで閉じる
nnoremap <silent> <expr> q meflib#basic#special_win(win_getid()) ? '<Cmd>quit<CR>' : 'q'

" terminal mode設定
if has('terminal') || has('nvim')
    " terminal-job modeからterminal-normal modeへの移行をescape*2で行えるようにする
    " (1回だと矢印を検知してしまうため2回にする)
    tnoremap <ESC><ESC> <c-\><c-n>
    " 新規タブ <Cmd> だと楽なのでこうする..
    tnoremap <c-t> <Cmd>tabnew<CR>
endif

" vim only
if has('terminal')
    " vimのterminalでterminal modeを抜けずに移動
    execute "tnoremap g\<Right\> ".&termwinkey."gt"
    execute "tnoremap g\<Left\> ".&termwinkey."gT"
    execute "tnoremap s\<Up\> ".&termwinkey."k"
    execute "tnoremap s\<Down\> ".&termwinkey."j"
    execute "tnoremap s\<Right\> ".&termwinkey."l"
    execute "tnoremap s\<Left\> ".&termwinkey."h"
elseif has('nvim')
    " NeoVimのterminalで(terminal modeを抜けずに)移動
    tnoremap g<Right> <c-\><c-n>gt
    tnoremap g<Left> <c-\><c-n>gT
    tnoremap s<Up> <c-\><c-n><c-w>k
    tnoremap s<Down> <c-\><c-n><c-w>j
    tnoremap s<Right> <c-\><c-n><c-w>l
    tnoremap s<Left> <c-\><c-n><c-w>h
endif

" VS Code を見習って，<c-b> で左端のwindowを閉じる
function! <SID>close_sidebar() abort
    let winid = win_getid(1)
    if meflib#basic#special_win(winid)
        " call win_execute(winid, 'quit')
        " execute() を使うとvimでindent-guidesがエラーを吐くので...
        let cur_winnr = winnr()
        1wincmd w
        quit
        execute cur_winnr-1..'wincmd w'
    endif
endfunction
nnoremap <silent> <c-b> <Cmd>call <SID>close_sidebar()<CR>

" : で:-like q: を起動
" は手癖と合わないので一旦消す
" nnoremap : q:

