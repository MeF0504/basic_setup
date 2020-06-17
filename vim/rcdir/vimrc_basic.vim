"" basic setup Run Command file.
"" 基本的にはset, map系のみ書かれており、autcmd, 関数などはなし。
"" のちのちversion依存、コンパイル依存もちゃんと書いていきたい。
"" 日本語なしは諦めた

" 単体で動かすことも考えて
set encoding=utf-8
scriptencoding utf-8

""########## tips {{{
" ##### shortcut comment
" <c-h> ... backspace <c-m> ... Enter
" <c-i> ... tab <c-j> ... Enter?
" ##### useful command
" :set          ... Show all options that differ from their default value.
" :set all      ... Show all but terminal options.
" :set termcap  ... Show all terminal options.
" :map          ... Show all mapping settings.
" :highlight    ... Show all highlight settings.
" command       ... Show all user commands.
" ##### other topics
" about command args... <f-args>=string, <args>=value
" about equation operator ...  (sorry for Japanese)
"   ==#, !=#, ># etc..    ：大文字小文字を区別する
"   ==?, !=?, >? etc..    ：大文字小文字を区別しない
"   =~, =~#, =~?          ：正規表現マッチ
"   !~, !~#, !~?          ：正規表現非マッチ
" 正規表現については :h pattern-overview or https://vim-jp.org/vimdoc-ja/pattern.html#pattern-overview
"" }}}

""##########基本設定 "{{{
"左端に数字を表示
set number
"常にステータスラインを表示
set laststatus=2
"コマンドラインの画面上の行数
set cmdheight=2
"カーソルの位置を表示
set ruler
"文の折り返し
set wrap
"タイトルを非表示
set notitle
"viとの互換性をとらない
set nocompatible
"タブをスペースに変換
set expandtab
"タブの幅
set tabstop=4
"オートインデントの幅
set shiftwidth=0    " 0 ... tabstopの値を使う
"連続した空白でtabやback spaceが動く幅
set softtabstop=-1  " 0 ... off, -1 ... shiftwidthの値を使う
"自動でインデントを挿入
set autoindent
"末尾の文字に応じて自動でindentを増減
set smartindent
"文字の色づけ ... onだと現状の設定を破棄する。詳しくは:h :syntax-on
syntax enable
"検索したときにハイライト
set hlsearch
"右下に入力コマンドを表示
set showcmd
"バックスペースのノーマルモード、(改行、)オートインデントへの有効化
set backspace=start,indent
"set backspace=start,eol,indent
"挿入モードでのマウスの有効化
set mouse=i
if !exists('$SSH_CONNECTION')   " localのときのみ
    "全モードでのマウスの有効化
    set mouse=a
endif
"大文字、小文字を区別しない
set ignorecase
"検索文字に大文字があると区別する
set smartcase
"タブとかを可視化?
set list
set listchars=tab:».,trail:\ ,extends:»,precedes:«,nbsp:% ",eol:↲
if !exists('$SSH_CONNECTION')   " localのときのみ
    "clipboardとyankを共有 (+clipboardが条件)
    set clipboard+=unnamed
endif
"検索のときに移動しない
set noincsearch
"カーソルが上下2行に行ったらスクロール
set scrolloff=2
"候補の出方を良い感じに
"http://boscono.hatenablog.com/entry/2013/11/17/230740
set wildmenu
set wildmode=longest,full
set foldenable
set foldmethod=marker
"縦分割時に右に出る
set splitright
"Leaderを<space>に設定
let mapleader = "\<space>"
"doc directoryを追加
if exists('g:vimdir') && isdirectory(g:vimdir . 'doc')
    execute "helptags " . g:vimdir . "doc"
endif

"カーソルの下に下線を表示
set cursorline

"swp fileあり、backup, undoなし
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

"tag設定
set tags=tags;,./tags;

" 左端にfoldの表示を追加
set foldcolumn=2

"terminal mode設定
"Nothing

" neovim specified config
if has('nvim')
    " pop-up menuを半透明にする [0-100(%)]
    set pumblend=20
    " 置換をinteractiveに行う
    set inccommand=split
else
    if has('terminal')
        "terminal-job modeでのwindow移動short cutを変更
        set termwinkey=<c-l>
    endif
endif

"grepコマンドで内部grep(vimgrep)を使う
"set grepprg=internal
"外部grepを数字付き,再帰的,大文字小文字区別なし,binary無視で使う
set grepprg=grep\ -nriI

" 基本的なstatusline 設定
set statusline=%f%m%r%h%w%<%=%y\ %l/%L\ [%P]
" 分割したwindow間で移動を同期
" (それぞれのwindowでsetする必要あり)
" set scrollbind
"}}}

""##########mapping設定 "{{{

" 誤って使うとまずいkeymapを削除
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap Q <Nop>

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
nnoremap <silent> 0gt :tablast<CR>
nnoremap <silent> g> :tabmove +1<CR>
nnoremap <silent> g< :tabmove -1<CR>
" 画面自体を左右に移動
nnoremap H 5zh
nnoremap L 5zl

" commandlineでも<c-a>で最初に戻りたい
cnoremap <c-a> <c-b>

" fold関連
" 大文字にするとファイル全体に適用
nnoremap zO zR
nnoremap zC zM
" Yで行末までヤンク
nnoremap Y y$
vnoremap Y $y
" 右方向で再帰的に開く
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zO' : 'l'
nnoremap <expr> <Right> foldclosed(line('.')) != -1 ? 'zO' : 'l'
" Enterで１段開いたり閉じたりする
nnoremap <expr> <CR> foldlevel('.') != 0 ? 'za' : '<CR>'

" shiftは逆動作だと思ってるので、単語移動をremap
noremap W b
noremap gw W
noremap gW B
noremap E ge
noremap ge E

" ヘッダーファイルをタブで開く
nnoremap gf <c-w>gf

" tag jump
" 候補が複数ある場合にリストを表示
nnoremap <c-]> g<c-]>
" 分割で表示
nnoremap <silent> g<c-]> :vertical stjump<CR>
" preview で開く
nnoremap <silent> <c-l> :execute("ptjump " . expand("<cword>"))<CR>

" \で検索のハイライトを消す
nnoremap <silent> \ :nohlsearch<CR>

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
endif

" }}}

