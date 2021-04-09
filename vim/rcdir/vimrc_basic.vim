"" basic setup Run Command file.
"" 基本的にはset, map系のみ書かれており、autcmd, 関数などはなし。
"" のちのちversion依存、コンパイル依存もちゃんと書いていきたい。
""  -> 書き始めた。とりあえず問題が起きたやつは全部書いていこうと思う。
"" 日本語なしは諦めた

" 単体で動かすことも考えて
set encoding=utf-8
scriptencoding utf-8

""########## tips {{{
" ##### shortcut comment
" <c-h> ... backspace <c-m> ... Enter
" <c-i> ... tab <c-j> ... Down

" ##### useful command
" :set          ... Show all options that differ from their default value.
" :set all      ... Show all but terminal options.
" :set termcap  ... Show all terminal options.
" :map          ... Show all mapping settings.
" :highlight    ... Show all highlight settings.
" command       ... Show all user commands.

" ##### spell check
" information; :h spell or https://vim-jp.org/vimdoc-ja/spell.html
" on; :setlocal spell spelllang=en_us
" search;
" 次を検索 ]s or ]S
" 前を検索 [s or [S
" (カーソル下を)正しい(good)単語として登録      zg or :spe[llgood] {word}
" (カーソル下を)間違った(wrong)単語として登録   zw or :spellw[rong] {word}
" (カーソル下の?)単語を一覧から削除             zuw / zug / :spellu[ndo] {word}

" ##### other topics
" about command args... <f-args>=string, <args>=value
" about equation operator ...  (sorry for Japanese)
"   ==#, !=#, ># etc..    ：大文字小文字を区別する
"   ==?, !=?, >? etc..    ：大文字小文字を区別しない
"   =~, =~#, =~?          ：正規表現マッチ
"   !~, !~#, !~?          ：正規表現非マッチ
" 正規表現については :h pattern-overview or https://vim-jp.org/vimdoc-ja/pattern.html#pattern-overview
" about SID
" :scriptnames          ... List all sourced script names
" :echo expand('<SID>') ... Get the current file SID

"" }}}

""##########基本設定 "{{{
" 左端に数字を表示
set number
" 常にステータスラインを表示
set laststatus=2
" コマンドラインの画面上の行数
set cmdheight=2
" カーソルの位置を表示
set ruler
" 文の折り返し
set wrap
" タイトルを非表示
set notitle
" viとの互換性をとらない
set nocompatible
" タブをスペースに変換
set expandtab
" タブの幅
set tabstop=4
" オートインデントの幅
set shiftwidth=0    " 0 ... tabstopの値を使う
" 連続した空白でtabやback spaceが動く幅
set softtabstop=-1  " 0 ... off, -1 ... shiftwidthの値を使う
" 自動でインデントを挿入
set autoindent
" 末尾の文字に応じて自動でindentを増減
set smartindent
" 文字の色づけ ... onだと現状の設定を破棄する。詳しくは:h :syntax-on
syntax enable
" 検索したときにハイライト
set hlsearch
" 右下に入力コマンドを表示
set showcmd
" バックスペースのノーマルモード、(改行、)オートインデントへの有効化
set backspace=start,indent
" set backspace=start,eol,indent
" 挿入モードでのマウスの有効化
set mouse=i
if !exists('$SSH_CONNECTION')   " localのときのみ
    " 全モードでのマウスの有効化
    set mouse=a
endif
" 大文字、小文字を区別しない
set ignorecase
" 検索文字に大文字があると区別する
set smartcase
" タブとかを可視化?
set list
set listchars=tab:».,trail:\ ,extends:»,precedes:«,nbsp:% ",eol:↲
if !exists('$SSH_CONNECTION')   " localのときのみ
    " clipboardとyankを共有 (+clipboardが条件)
    set clipboard+=unnamed
endif
" 検索のときに移動しない
set noincsearch
" カーソルが上下2行に行ったらスクロール
set scrolloff=2
" 候補の出方を良い感じに
" http://boscono.hatenablog.com/entry/2013/11/17/230740
set wildmenu
set wildmode=longest,full
set foldenable
set foldmethod=marker
" 縦分割時に右に出る
set splitright
" Leaderを<space>に設定
let mapleader = "\<space>"
" doc directoryを追加
if exists('g:vimdir') && isdirectory(g:vimdir . 'doc')
    execute "helptags " . g:vimdir . "doc"
endif
" ファイル名が=で切られないようにする (ファイル名に=は使わないよな...)
set isfname-==
" pythonxで使うversionを指定
" set pyxversion=3    " if needed
" カーソルの下に下線を表示
set cursorline
" swp fileあり、backup, undoなし
set swapfile
" 作れればswp用のdirectoryをvimdir配下に作る
if exists('g:vimdir')
    if !isdirectory(g:vimdir . 'swp')
        call mkdir(g:vimdir . 'swp')
    endif
    let &directory = g:vimdir . "swp"
endif
set nobackup
set noundofile
" tag設定
set tags=tags;,./tags;
" 左端にfoldの表示を追加
set foldcolumn=2
" grepコマンドで内部grep(vimgrep)を使う
" set grepprg=internal
" 外部grepを数字付き,再帰的,大文字小文字区別なし,binary無視で使う
set grepprg=grep\ -nriI
" 最終行にmodeを表示する
set showmode
" 右下に検索のカウント数を表示 if needed
" if (v:version > 801) || ((v:version==801) && has('patch1270')) || has('neovim')
"     set shortmess-=S
" endif
" 分割したwindow間で移動を同期
" (それぞれのwindowでsetする必要あり)
" set scrollbind
" エコーエリアに補完時のメッセージ (match n of Nとか)を表示しない
if (v:version > 704) || ((v:version==704) && has('patch314'))
    set shortmess+=c
endif
" spell checkする言語
set spelllang=en_us
" spell checkされた単語リストファイル
if exists('g:vimdir')
    if !isdirectory(g:vimdir.'spell')
        call mkdir(g:vimdir.'spell')
    endif
    let &spellfile = g:vimdir.'spell/local.'.&encoding.'.add'
endif

" terminal mode設定
" Nothing

" neovim specified config
if has('nvim')
    if has('nvim-0.4.0')
        " pop-up menuを半透明にする [0-100(%)]
        " やっぱり見づらいので0にする...
        set pumblend=0
    endif
    if has('nvim-0.2.0')
        " 置換をinteractiveに行う
        set inccommand=split
    endif
else
    if has('terminal')
        "terminal-job modeでのwindow移動short cutを変更
        set termwinkey=<c-l>
    endif
endif

" 基本的なstatusline 設定
set statusline=%f%m%r%h%w%<%=%y\ %l/%L\ [%P]

" In case vim don't read vimrc_color.vim
if !exists('g:vimdir')
    colorscheme desert
endif

" tex flavor
let g:tex_flavor = 'latex'
" default shell script type
let g:is_bash = 1

"}}}

""##########mapping設定 "{{{

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
nnoremap <silent> <c-p> :execute("ptjump " . expand("<cword>"))<CR>

" \で検索のハイライトを消す
nnoremap <silent> \ :nohlsearch<CR>

" 1行複製をよく使うので...
nnoremap yp yyp

" preview , nofile, quickfix windowはqで閉じる
function! <SID>close_con()
    return
            \ (&previewwindow==1)
            \ || (&buftype=='nofile')
            \ || (&filetype=='qf')
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
    " termwinkey = <c-l>
    tnoremap g<Right> <c-l>gt
    tnoremap g<Left> <c-l>gT
    tnoremap s<Up> <c-l><c-w>k
    tnoremap s<Down> <c-l><c-w>j
    tnoremap s<Right> <c-l><c-w>l
    tnoremap s<Left> <c-l><c-w>h
endif

" }}}

