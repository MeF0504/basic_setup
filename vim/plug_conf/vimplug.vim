" 少なくとも50行を超えたら別枠にする

" Anywhere SID.
function! s:SID_PREFIX() " tentative
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
if empty(expand('<SID>'))
    let s:sid = s:SID_PREFIX()
else
    let s:sid = expand('<SID>')
endif

let s:map_cmds = {}
function! s:map_util(name) abort " {{{
    if !has_key(s:map_cmds, a:name)
        echo 'incorrect map name'
        return
    endif
    let cmds = s:map_cmds[a:name]
    if empty(cmds)
        echo 'no maps'
        return
    endif
    let old_cmdheight = &cmdheight
    let &cmdheight = len(cmds)+1
    echo map(deepcopy(cmds),
                \ {key, val -> key..': '..val})->values()->join("\n").."\n"
    " let key = input('key: ')
    let key = getcharstr()
    let &cmdheight = old_cmdheight
    if has_key(cmds, key)
        execute cmds[key]
    endif
endfunction
" }}}

" joke command
Plug 'MeF0504/sl.vim', PlugCond(1, {'on': 'SL'})

" Project Sekai inspired plugin
Plug 'MeF0504/untitled.vim'
" untitled {{{
function! s:untitled_his() abort
    try
        let bc = untitled#get_birthday_color()
        if !empty(bc)
            execute printf('highlight CursorLineNr ctermbg=%s ctermfg=0 guibg=%s guifg=Black', bc.cterm, bc.gui)
        endif
    endtry
endfunction
call meflib#add('plugin_his', s:sid.'untitled_his')
" }}}

" Syntax 情報をpopupで表示
Plug 'MeF0504/vim-popsyntax', PlugCond(1, {'on': 'PopSyntaxToggle'})
" popsyntax {{{
let g:popsyntax_match_enable = 1
" }}}

" ctagsを使ってhighlightを設定 (mftags 分割 その1)
Plug 'MeF0504/highlightag.vim'
"" highlightag {{{
if has('nvim')
    autocmd PlugLocal VimEnter,BufWinEnter *
    \ if &filetype == 'c' |
    \ silent call highlightag#run_hitag_job_file() |
    \ else |
    \ silent call highlightag#run_hitag_job() |
    \ endif
else
    autocmd PlugLocal Syntax *
    \ if &filetype == 'c' |
    \ silent call highlightag#run_hitag_job_file() |
    \ else |
    \ silent call highlightag#run_hitag_job() |
    \ endif
endif
" highlights
function! <SID>highlightag_his() abort
    if &background == 'dark'
        highlight default HiTagClasses ctermfg=171 guifg=#d75fff
        highlight default HiTagMembers ctermfg=69 guifg=#5f87ff
    else
        highlight default HiTagClasses ctermfg=52 guifg=#a63095
        highlight default HiTagMembers ctermfg=24 guifg=#2860af
    endif
endfunction
call meflib#add('plugin_his', s:sid.'highlightag_his')
" }}}

" vim plugin like chrome://dino
Plug 'MeF0504/dino.vim', PlugCond(1, {'on': 'Dino'})

" git log 表示用plugin
Plug 'MeF0504/gitewer.vim', PlugCond(1, {'on': 'Gitewer'})
" {{{ gitewer, git
let s:map_cmds['git'] = {}
let s:map_cmds['git']['w'] = "Gitewer status"
nnoremap <leader>g <Cmd>call <SID>map_util('git')<CR>
" }}}

" vim-pets extension
Plug 'MeF0504/vim-pets-ocean', PlugCond(1, {'on': 'Pets'})
Plug 'MeF0504/vim-pets-codes', PlugCond(1, {'on': 'Pets'})

" paste時に履歴から選ぶ
Plug 'MeF0504/RegistPaste.vim'

" tab の一覧表示＆ジャンプ
Plug 'MeF0504/vim-TabJumper', PlugCond(1, {'on': 'TabJump'})
" TabJumper {{{
nnoremap <leader>l <Cmd>TabJump<CR>
tnoremap <c-l><c-l> <Cmd>TabJump<CR>
let g:tabjumper_preview_enable = 'manual'
let g:tabjumper_preview_width = &columns-20
" }}}

" neosnippet用のsnipets
Plug 'Shougo/neosnippet-snippets'

" 背景透過
Plug 'miyakogi/seiya.vim', PlugCond(1, {'on': ['SeiyaEnable', 'SeiyaDisable']})
"" seiya.vim "{{{
let g:seiya_auto_enable=0
if has('termguicolors') && !has('gui_running')
    let g:seiya_target_groups = ['ctermbg', 'guibg']
endif
function! <SID>seiya_his() abort
    if &background == 'light'
        silent SeiyaDisable
    elseif g:colors_name =~ 'pjsekai_*'
        silent SeiyaDisable
    else
        SeiyaEnable
    endif
endfunction
call meflib#add('plugin_his', s:sid.'seiya_his')
"}}}

" 検索時にhit数をcountしてくれるplugin
Plug 'osyo-manga/vim-anzu', PlugCond(!meflib#get('load_plugin', 'hitspop', 0), {'on':[]})
"" vim-anzu {{{
if !meflib#get('load_plugin', 'hitspop', 0)
    " highlights
    function! <SID>anzu_his() abort
        highlight default AnzuPopup ctermfg=224 ctermbg=238 guifg=#ffd7d7 guibg=#444444
    endfunction
    call meflib#add('plugin_his', s:sid.'anzu_his')
    call meflib#add('lazy_plugins', 'vim-anzu')
    " max search count
    let g:anzu_search_limit = 3000
    " mapping
    nmap n <Plug>(anzu-n-with-echo)
    nmap N <Plug>(anzu-N-with-echo)

    let s:anzu_bufid = -1
    let s:anzu_popid = -1
    function! <SID>Show_anzu_float() abort
        if !exists('g:loaded_anzu')
            return
        endif
        " update status. if it takes time, cancel this.
        AnzuUpdateSearchStatus
        let anzu_str = anzu#search_status()
        if empty(anzu_str)
            call meflib#floating#close(s:anzu_popid)
            let s:anzu_popid = -1
            return
        endif
        let config = {
            \ 'relative': 'win',
            \ 'line': winheight(0),
            \ 'col': winwidth(0),
            \ 'pos': 'botright',
            \ 'highlight': 'AnzuPopup',
            \ }
            let [s:anzu_bufid, s:anzu_popid] = meflib#floating#open(s:anzu_bufid, s:anzu_popid, [anzu_str], config)
    endfunction
    nnoremap <silent> \ <Cmd>call anzu#clear_search_status() <bar> nohlsearch<CR>
    autocmd PlugLocal CursorMoved * call <SID>Show_anzu_float()
    autocmd PlugLocal TabLeave * call meflib#floating#close(s:anzu_popid) | let s:anzu_popid=-1
    autocmd PlugLocal QuitPre * call meflib#floating#close(s:anzu_popid) | let s:anzu_popid=-1
endif
" }}}

" if - endif 等を補完してくれるplugin
Plug 'tpope/vim-endwise'
"" endwise {{{
autocmd PlugLocal FileType html
        \ let b:endwise_addition = '\=submatch(0)=="html" ? "\</html\>" : submatch(0)=="head" ? "\</head\>" : submatch(0)=="body" ? "\</body\>" : submatch(0)=="script" ? "\</script\>" : "\</style\>"' |
        \ let b:endwise_words = 'html,head,body,script,style' |
        \ let b:endwise_syngroups = 'htmlTagName,htmlSpecialTagName'
" https://github.com/tpope/vim-endwise/issues/83
autocmd PlugLocal FileType tex
        \ let b:endwise_addition = '\="\\end" . matchstr(submatch(0), "{.\\{-}}")' |
        \ let b:endwise_words = 'begin' |
        \ let b:endwise_pattern = '\\begin{.\{-}}' |
        \ let b:endwise_syngroups = 'texSection,texBeginEnd,texBeginEndName,texStatement'
"}}}

" vim の document
Plug 'vim-jp/vimdoc-ja'
" {{{
" https://gorilla.netlify.app/articles/20190427-vim-help-jp.html
" helpを日本語優先にする
" if !has('nvim')
autocmd PlugLocal User vimdoc-ja set helplang=ja
" endif
" }}}

" for deoplete and wilder
" vim でneovim 用 pluginを動かすためのplugin
Plug 'roxma/nvim-yarp', PlugCond(!has('nvim'))

" for deoplete and wilder
" vim でneovim 用 pluginを動かすためのplugin
Plug 'roxma/vim-hug-neovim-rpc', PlugCond(!has('nvim'))

" visual modeで選択した範囲をgcでコメントアウトしてくれるplugin
Plug 'tpope/vim-commentary'
call meflib#add('del_commands', 'Commentary')

" 検索のhit数をpopupで表示するplugin
Plug 'obcat/vim-hitspop', PlugCond(meflib#get('load_plugin', 'hitspop', 0))
" {{{
if meflib#get('load_plugin', 'hitspop', 0)
    " https://zenn.dev/obcat/articles/4ef6822de53b643bbd01
    " :nohlsearch で消える→ 自分は\で消える
    " 右下に表示
    let g:hitspop_line = 'winbot'
    let g:hitspop_column = 'winright'
    " highlights
    function! <SID>hitspop_his() abort
        highlight default hitspopNormal ctermfg=224 ctermbg=238 guifg=#ffd7d7 guibg=#444444
        highlight default hitspopErrorMsg ctermfg=9 ctermbg=238 guifg=Red guibg=#444444
    endfunction
    call meflib#add('plugin_his', s:sid.'hitspop_his')
endif
" }}}

" 英語翻訳プラグイン
" https://qiita.com/gorilla0513/items/37c80569ff8f3a1c721c
" translate.vim はarchive された模様。new oneに移行
" ondemand loadするとコケる
Plug 'skanehira/denops-translate.vim', PlugCond(meflib#get('deno_on', 0))
" denopsが動かない場合に欲しいのでやむなく復活
Plug 'skanehira/translate.vim', PlugCond(!meflib#get('deno_on', 0))
" {{{
" for translate.vim
let g:translate_popup_window = 0
" for denops-translate.vim
let g:translate_ui = 'buffer'
" both
let g:translate_source = 'en'
let g:translate_target = 'ja'
" }}}

" カーソル下の変数と同じ変数に下線
Plug 'itchyny/vim-cursorword'
" {{{
" デフォルトのhighlightをoff
let g:cursorword_highlight = 0
" 幾つかのfile typeではcursorwordをoff
autocmd PlugLocal FileType txt,help,markdown,taglist,outliner
            \ let b:cursorword = 0
" highlights
function! <SID>cursorword_his() abort
    highlight default CursorWord1 ctermfg=None ctermbg=None cterm=None guifg=NONE guifg=NONE gui=NONE
    highlight default CursorWord0 ctermfg=None ctermbg=None cterm=underline guifg=NONE guifg=NONE gui=Underline
    " CursorWord[01] is not supported? or CursorWord is required?
    highlight default CursorWord ctermfg=None ctermbg=None cterm=underline,bold guifg=NONE guifg=NONE gui=Underline,bold

endfunction
call meflib#add('plugin_his', s:sid.'cursorword_his')
" }}}

" An ecosystem of Vim/Neovim which allows developers to write plugins in Deno. だそうです
" for ddc.vim and translate.vim
Plug 'vim-denops/denops.vim', PlugCond(meflib#get('load_plugin', 'denops', 0))

" denops test
Plug 'vim-denops/denops-helloworld.vim', PlugCond(meflib#get('load_plugin', 'denops', 0))

" indent のlevelを見やすくする
Plug 'nathanaelkane/vim-indent-guides'
"" indent-guides {{{
" vim 起動時に起動
let g:indent_guides_enable_on_vim_startup = 1
" 色は自分で設定
let g:indent_guides_auto_colors = 0
" 2個目のindentから色をつける
let g:indent_guides_start_level = 2
" 1文字分だけ色つけ
let g:indent_guides_guide_size = 1
" mapは無し
let g:indent_guides_default_mapping = 0
" highlights
function! <SID>indentguide_his() abort
    if &background == 'dark'
        highlight default IndentGuidesOdd ctermfg=17 ctermbg=17 guifg=#003851 guibg=#003851
        highlight default IndentGuidesEven ctermfg=54 ctermbg=54 guifg=#3f0057 guibg=#3f0057
    else
        highlight default IndentGuidesOdd ctermfg=159 ctermbg=159 guifg=#e0f8ff guibg=#e0f8ff
        highlight default IndentGuidesEven ctermfg=225 ctermbg=225 guifg=#ffe0fd guibg=#ffe0fd
    endif
endfunction
call meflib#add('plugin_his', s:sid.'indentguide_his')
let g:indent_guides_exclude_filetypes = split('help taglist git')
" }}}

" vim 新機能用pluginっぽい
" showcase of new vim functions.
Plug 'vim/killersheep', PlugCond(has('patch-8.1.1705'), {'on': 'KillKillKill'})

" toml 用 syntax
Plug 'cespare/vim-toml', PlugCond(!has('patch-8.2.2106'), {'for': 'toml'})

" ファイルの一部のsyntax highlightを違うfiletypeにする
Plug 'inkarkat/vim-SyntaxRange', PlugCond(1, {'for': ['toml', 'markdown', 'vim']})
" {{{
function! s:syntaxRange_hook() abort
    if &filetype == 'toml'
        " call s:syntax_range_dein()
        " autocmdのタイミングが悪い (vim-tomlに上書きされる)ので，調整
        " autocmd PlugLocal BufNewFile,BufRead dein*.toml call s:syntax_range_dein()
        autocmd PlugLocal BufWinEnter dein*.toml call s:syntax_range_dein()
    elseif &filetype == 'markdown'
        " call s:syntax_range_md()
        autocmd PlugLocal BufWinEnter *.md call s:syntax_range_md()
    elseif &filetype == 'vim'
        call s:syntax_range_vim()
        autocmd PlugLocal BufWinEnter *.vim call s:syntax_range_vim()
    endif
endfunction
" https://qiita.com/tmsanrinsha/items/9670628aef3144c7919b
" Insertで戻る... 要検討 ... とりあえず:eで再表示
function! s:syntax_range_dein() abort
    let start = '^\s*hook_\%('.
                \ 'add\|source\|post_source\|post_update'.
                \ '\)\s*=\s*%s'
    call SyntaxRange#Include(printf(start, "\'\'\'"), "\'\'\'", 'vim', '')
    call SyntaxRange#Include(printf(start, '"""'), '"""', 'vim', '')
endfunction

function! s:syntax_range_md() abort
    call SyntaxRange#Include('^\s*```\s*vim', '```', 'vim', '')
endfunction

function! s:syntax_range_vim() abort
    let start = '^\s*python[3x]*.*EOL$'
    call SyntaxRange#Include(start, 'EOL', 'python', '')
endfunction
autocmd PlugLocal User vim-SyntaxRange call s:syntaxRange_hook()
" autocmd PlugLocal VimEnter * call s:syntaxRange_hook()
" }}}

" 上のpluginで使われるやつ
Plug 'inkarkat/vim-ingo-library', PlugCond(1, {'for': ['toml', 'markdown']})

" vim でsnippet を使う用の plugin (framework?)
Plug 'Shougo/neosnippet.vim'

" vim script 用補完 plugin
Plug 'Shougo/neco-vim', PlugCond(1, {'for': 'vim'})

" vimの編集履歴を表示／適用してくれる plugin
Plug 'sjl/gundo.vim', PlugCond(1, {'on': 'GundoToggle'})
" {{{ "Gundo
" if has('python3') " pythonをcheckするのに時間が掛かっているっぽい
let g:gundo_prefer_python3 = 1
" endif
nnoremap <silent> <Leader>u <Cmd>GundoToggle<CR>
" }}}

" カーソルの下の文字とかをhighlight
Plug 'azabiong/vim-highlighter', PlugCond(1, {'on': 'Hi'})
" {{{
let g:HiClear = '\\'
function! s:highlighter_map() abort
    let cword = expand('<cword>')
    for mat in getmatches()
        if has_key(mat, 'pattern') && cword =~# mat.pattern
            if mat.group =~ "HiColor"
                return "\<Cmd> Hi -\<CR>"
            endif
        endif
    endfor
    return ":\<c-u>Hi + "
endfunction
nnoremap <expr> // <SID>highlighter_map()
" }}}

" git の現在行のコミット履歴を辿る
Plug 'rhysd/git-messenger.vim', PlugCond(1, {'on': 'GitMessenger'})
" git messenger {{{
let g:git_messenger_no_default_mappings = v:true
let g:git_messenger_floating_win_opts = {'border': 'single'}
let s:map_cmds['git']['m'] = "GitMessenger"
" nnoremap <leader>gm <Cmd>GitMessenger<CR>
autocmd PlugLocal FileType gitmessengerpopup
            \ nnoremap <buffer> q <Cmd>GitMessengerClose<CR>
" }}}

" plugin のdot repeatをサポート (RegistPasteで使用)
Plug 'tpope/vim-repeat'

" syntax file etc. for fish script
Plug 'dag/vim-fish', PlugCond(1, {'for': 'fish'})

" a fundemental plugin to handle Nerd Fonts from Vim. (for Fern)
Plug 'lambdalisue/nerdfont.vim'

" vim bookmark
Plug 'MattesGroeger/vim-bookmarks', PlugCond(1, {'on': ['BookmarkToggle', 'BookmarkAnnotate']})
" bookmarks {{{
let g:bookmark_no_default_key_mappings = 1
let g:bookmark_auto_save = 0
let g:bookmark_disable_ctrlp = 1
let g:bookmark_display_annotation = 0
let s:map_cmds['Bookmark'] = {
            \ 'm': 'BookmarkToggle',
            \ 'i': 'BookmarkAnnotate',
            \ 'a': 'BookmarkShowAll',
            \ }
nnoremap <leader>m <Cmd>call <SID>map_util('Bookmark')<CR>
function! s:bookmarks_his() abort
    let [ctermbg, guibg] = meflib#basic#get_hi_info('SignColumn', ['ctermbg', 'guibg'])
    execute printf("highlight default BookmarkSign ctermfg=105 ctermbg=%s guifg=#8787ff guibg=%s", ctermbg, guibg)
    execute printf("highlight BookmarkAnnotationSign ctermfg=51 ctermbg=%s guifg=#30ffe8 guibg=%s", ctermbg, guibg)
endfunction
call meflib#add('plugin_his', s:sid.'bookmarks_his')
" }}}

" 色々な言語のtemplate
Plug 'mattn/vim-sonictemplate', PlugCond(1)
" {{{
let g:sonictemplate_vim_template_dir = meflib#basic#get_conf_dir()..'plug_conf/templates'
let g:sonictemplate_key = "\<c-q>\<c-q>"
let g:sonictemplate_intelligent_key = "\<c-q>\<c-a>"
nmap <leader>a :<C-u>Template 
" }}}

" window のresize, 移動用plugin
Plug 'simeji/winresizer', PlugCond(1, {'on': 'WinResizerStartResize'})
" {{{
nnoremap <leader>w <Cmd>WinResizerStartResize<CR>
let g:winresizer_finish_with_escape = 0
let g:winresizer_start_key = '<leader>w'
let g:winresizer_vert_resize = 5
let g:winresizer_horiz_resize = 2
" }}}

" typewriter sound in Vim
Plug 'skywind3000/vim-keysound', PlugCond(1, {'on': 'KeysoundEnable'})
" {{{
let g:keysound_enable = 0
" use KeysoundEnable/Disable
let g:keysound_theme = 'typewriter'
" }}}
