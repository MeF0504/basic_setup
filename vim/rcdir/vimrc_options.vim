" vim script encoding setting
scriptencoding utf-8
"" vim option settings

if exists('*meflib#basic#get_conf_dir')
    let s:vimdir = meflib#basic#get_conf_dir()
endif

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
" 検索したときにハイライト
set hlsearch
" 右下に入力コマンドを表示
set showcmd
" バックスペースのノーマルモード、(改行、)オートインデントへの有効化
set backspace=start,indent
" set backspace=start,eol,indent
if !exists('$SSH_CONNECTION')   " localのときのみ
    " 全モードでのマウスの有効化
    set mouse=a
else
    " 挿入モードでのマウスの有効化
    set mouse=i
endif
" 大文字、小文字を区別しない
set ignorecase
" 検索文字に大文字があると区別する
set smartcase
" タブとかを可視化?
set list
set listchars=tab:».,trail:\ ,extends:»,precedes:«,nbsp:% ",eol:↲
" clipboardとyankを共有 (+clipboardが条件)
if has('clipboard') && !exists('$SSH_CONNECTION')   " localのときのみ
    " なんか win/mac と linux で違うらしい
    if has('win32') || has('win64') || has('mac')
        set clipboard+=unnamed
    elseif has('unnamedplus')
        set clipboard+=unnamedplus
    endif
endif
" 検索のときに移動しない
set noincsearch
" カーソルが上下2行に行ったらスクロール
set scrolloff=2
" 候補の出方を良い感じに
" http://boscono.hatenablog.com/entry/2013/11/17/230740
set wildmenu
set wildmode=longest,full
" 折りたたみ
set foldenable
set foldmethod=marker
" 縦分割時に右に出る
set splitright
" Leaderを<space>に設定
let mapleader = "\<space>"
" ファイル名が=で切られないようにする (ファイル名に=は使わないよな...)
set isfname-==
" pythonxで使うversionを指定
" set pyxversion=3    " if needed
" カーソルの下に下線を表示
set cursorline
" tag設定
set tags+=tags;,./tags;
" 左端にfoldの表示を追加
set foldcolumn=2
" grep
if executable('grep')
    " 外部grepを数字付き,再帰的,大文字小文字区別なし,binary無視, .git dir無視で使う
    set grepprg=grep\ -nriI\ --exclude-dir\ .git
else
    " grepコマンドで内部grep(vimgrep)を使う
    set grepprg=internal
endif
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
" <c-a>, <c-x>の対称を10進数 (default)，16進数，2進数，unsignedにする
set nrformats=hex,bin
try
    set nrformats+=unsigned
catch
    " nothing
endtry
" terminalでもgui colorを使う
" set termguicolors " if needed
" windowsでgit bashから起動するとバグることが多々あるので。
if has('win32') || has('win64')
    set shell=cmd.exe
endif
" CursorHoldの時間
set updatetime=4000 " (default)

" directory 設定系
" 月1回helptags を実行
if exists('s:vimdir') && isdirectory(s:vimdir..'doc')
    let s:htagfs = glob(s:vimdir..'doc/tags*', 0, 1)
    if empty(s:htagfs)
        echomsg "exec helptags"
        execute "helptags " . s:vimdir . "doc"
    else
        for s:htagf in s:htagfs
            if localtime()-getftime(s:htagf) >= 3600*24*30
                echomsg "exec helptags"
                execute "helptags " . s:vimdir . "doc"
                break
            endif
        endfor
    endif
endif
" swp fileあり、backup, undoなし
set swapfile
" 作れればswp用のdirectoryをvimdir配下に作る
if exists('s:vimdir')
    if !isdirectory(s:vimdir . 'swp')
        call mkdir(s:vimdir . 'swp')
    endif
    let &directory = s:vimdir . "swp"
endif
set nobackup
set noundofile
" spell checkする言語
set spelllang=en_us
" spell checkされた単語リストファイル
if exists('s:vimdir')
    if !isdirectory(s:vimdir.'spell')
        call mkdir(s:vimdir.'spell')
    endif
    let &spellfile = s:vimdir.'spell/local.'.&encoding.'.add'
endif
" test用directoryを追加
if exists('s:vimdir')
    let s:test_vim_dir = s:vimdir..'test'
    if !isdirectory(s:test_vim_dir)
        call mkdir(s:test_vim_dir)
    endif
    if isdirectory(s:test_vim_dir..'/doc')
        execute "helptags "..s:test_vim_dir..'/doc'
    endif
    execute 'set runtimepath^='..substitute(s:test_vim_dir, ' ', '\\ ', 'g')
endif

" terminal mode設定
if has('terminal')
    "terminal-job modeでのwindow移動short cutを変更
    set termwinkey=<c-l>
endif

" 環境変数

" neovim specified config
if has('nvim')
    if has('nvim-0.4.0')
        " pop-up menuを半透明にする [0-100(%)]
        if &termguicolors
            " gui colorなら良さそう
            set pumblend=18
        else
            " ctermだと見づらいので0
            set pumblend=0
        endif
    endif
    if has('nvim-0.2.0')
        " 置換をinteractiveに行う
        set inccommand=split
    endif
endif

" 基本的なstatusline 設定
set statusline=%f%m%r%h%w%<%=%y\ %l/%L\ [%p%%]

" tex flavor
let g:tex_flavor = 'latex'
" default shell script type
let g:is_bash = 1

" terminalの色設定 (neovimはautocmdで)
if !has('nvim') && (has('patch-8.0.1685') || v:version>=801)
    " https://qiita.com/yami_beta/items/97480d5e88f0d867176b
    let g:terminal_ansi_colors = meflib#basic#get_term_color()
endif

