" vim script encoding setting
scriptencoding utf-8
"" vim map(key) settings

" 誤って使うとまずいkeymapを削除
" 保存して終了 :h ZZ
nnoremap ZZ <Nop>
" 保存せずに終了 :h ZQ
nnoremap ZQ <Nop>
" ex modeに切り替え。viの前身か？ :h Q
nnoremap Q <Nop>
" current windowを閉じる :h CTRL-W_q
nnoremap <c-w>q <Nop>
" sをctrl-wにmapしているので...
nnoremap sq <Nop>

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
nnoremap T :tabnew<space>

" quick fix window
nnoremap <silent> co :botright copen<CR>
nnoremap <silent> cc :cclose<CR>
nnoremap <silent> cn :cnewer<CR>
nnoremap <silent> cp :colder<CR>

" search
nnoremap / /\v
nnoremap * /\v<<c-r><c-w>><CR>

" tab 移動
nnoremap g<Right> gt
nnoremap g<Left> gT
nnoremap gl gt
nnoremap gh gT
" ↓ <num>gt に合わせて0gt
nnoremap <silent> 0gt :tablast<CR>
nnoremap <silent> g> :tabmove +1<CR>
nnoremap <silent> g< :tabmove -1<CR>
nnoremap <silent> g$> :tabmove $<CR>
nnoremap <silent> g0< :tabmove 0<CR>

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

" shiftは逆動作だと思ってるので、単語移動をremap
noremap W b
noremap gw W
noremap gW B
noremap E ge
noremap ge E

" 今の行を画面のtopにする。ctrl-lはterminalの感覚
nnoremap <c-l> z<CR>

" goto file をタブで開く
nnoremap gf <c-w>gf

" tag jump
" 候補が複数ある場合にリストを表示
nnoremap <c-]> g<c-]>
" 分割で表示
nnoremap <silent> g<c-]> :vertical stjump<CR>
" preview で開く
nnoremap <silent> <c-p> :execute "ptjump "..expand("<cword>")<CR>
"jump先をnew tabで開く
nnoremap <silent> <c-j> :execute "tab tjump "..expand("<cword>")<CR>

" \で検索のハイライトを消す
nnoremap <silent> \ :nohlsearch<CR>

" 1行複製をよく使うので...
nnoremap yp yyp
nnoremap yP yyP
nnoremap dp ddp
nnoremap dP ddkP

" preview , nofile, quickfix window, help windowはqで閉じる
function! <SID>close_con()
    return
            \ (&previewwindow==1)
            \ || (&buftype=='nofile')
            \ || (&filetype=='qf')
            \ || (&filetype=='help')
endfunction
nnoremap <silent> <expr> q <SID>close_con()==1 ? ':quit<CR>' : 'q'

" terminal mode設定
if has('terminal') || has('nvim')
    " terminal-job modeからterminal-normal modeへの移行をescape*2で行えるようにする
    " (1回だと矢印を検知してしまうため2回にする)
    tnoremap <ESC><ESC> <c-\><c-n>
    " (なんかescape 2回だとE21 cannot changeが出るので，ちょっと変えてみる...)
    " -> 直った？
    " tnoremap <ESC><C-e> <c-\><c-n>
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

