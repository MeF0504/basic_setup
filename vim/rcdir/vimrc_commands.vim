" vim script encoding setting
scriptencoding utf-8
"" simple commands and aliases

augroup cmdLocal
    autocmd!
augroup END

" DOC OPTIONS map_cmds
" dictionary for setting variable commands for one key.
" DOCEND

" {{{ 複数のコマンドで使われる設定
call meflib#set('exclude_dirs', ['.git', '.svn',
            \ '.mypy_cache', '.ipynb_checkpoints', '.pytest_cache',
            \ '.tagdir',
            \ ])
" DOC OPTIONS exclude_dirs
" set directories excluding from search.
" DOCEND
call meflib#set('side_width', min([45, &columns/16*5]))
" DOC OPTIONS side_width
" set width of optional window.
" DOCEND
" }}}
" 要らない？user関数を消す {{{
" DOC OPTIONS del_commands
" commands to be deleted before opening Vim.
" DOCEND
function! s:del_comds()
    let del_commands = meflib#get('del_commands', [])
    for dc in del_commands
        if exists(':'.dc) == 2
            execute 'delcommand '.dc
        endif
    endfor
endfunction
if v:vim_did_enter
    call s:del_comds()
else
    autocmd cmdLocal VimEnter * ++once call s:del_comds()
endif
" }}}

" map leader にmapされているmapを表示 {{{
" nnoremap <Leader><Leader> :map mapleader<CR>
function! <SID>leader_map()
    map <Leader>
endfunction
nnoremap <silent> <Leader><Leader> <Cmd>call <SID>leader_map()<CR>
" }}}
" diff系command {{{
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
" DOC COMMANDS DiffOrig
" DiffOrig
" 
" See |diff-original-file|
" DOCEND
command! -nargs=1 -complete=file Diff vertical diffsplit <args>
" DOC COMMANDS Diff
" Diff {filename}
" 
" Check the difference between current file and {filename}.
" DOCEND
"}}}
" conflict commentを検索 {{{
command! SearchConf /<<<<<<<\|=======\|>>>>>>>
" DOC COMMANDS SearchConf
" SearchConf
" 
" Search the conflict strings.
" Conflict strings are following; >
" 	<<<<<<<
" 	=======
" 	>>>>>>>
" <
" DOCEND
" }}}
" ipython を呼ぶ用 {{{
let s:ipythons = {'ipython':'Ipython', 'ipython2':'Ipython2', 'ipython3':'Ipython3'}
let s:ipy_ac = 1
for [s:sh_cmd, s:vim_cmd] in items(s:ipythons)
    if executable(s:sh_cmd)
        if has('nvim')
            execute printf('command! %s botright <mods> new | setlocal nonumber | terminal %s', s:vim_cmd, s:sh_cmd)
            if s:ipy_ac
                autocmd cmdLocal TermOpen *ipython* startinsert
                let s:ipy_ac = 0
            endif
        else
            execute printf('command! %s botright <mods> terminal %s', s:vim_cmd, s:sh_cmd)
        endif
    endif
endfor
" DOC COMMANDS Ipython
" Ipython
"
" run ipython in new tab.
" DOCEND
" DOC COMMANDS Ipython3
" Ipython3
"
" run ipython3 in new tab.
" DOCEND
" }}}
" Spell check {{{
command! Spell if &spell!=1 | setlocal spell | echo 'spell: on' | else | setlocal nospell | echo 'spell: off' | endif
" DOC COMMANDS Spell
" Spell
"
" Toggle 'spell'.
" DOCEND
" }}}
" 開いているファイル情報を表示（ざっくり）{{{
command! -nargs=? -complete=file FileInfo call meflib#fileinfo#main(<f-args>)
" DOC COMMANDS FileInfo
" FileInfo [file]
"
" Show the information of the [file].
" If [file] is not specified, show the information of the current file.
" Python support is required.
" DOCEND
" }}}
" 辞書（というか英辞郎）で検索 {{{
command! -nargs=1 EijiroWeb call meflib#tools#eijiro(<f-args>)
" DOC COMMANDS EijiroWeb
" EijiroWeb {word}
" 
" Search the {word} in the eijiro web page (https://eowf.alc.co.jp/).
" DOCEND
" }}}
" ctags command {{{
command! -nargs=? -complete=dir Ctags call meflib#tools#exec_ctags(<f-args>)
" DOC COMMANDS Ctags
" Ctags
" 
" Execute ctags command.
" Also see |meflib-opt-ctags_opt|.
" DOCEND
" }}}
" job status check {{{
command! JobStatus call meflib#tools#chk_job_status()
" DOC COMMANDS JobStatus
" JobStatus
" 
" Show the job status.
" DOCEND
" }}}
"vimでbinary fileを閲覧，編集 "{{{
command! BinMode call meflib#tools#BinaryMode()
" DOC COMMANDS BinMode
" BinMode
" 
" Set the current file as a bin file and move to bin mode.
" Also refer |using-xxd|.
" DOCEND
" }}}
" termonal commandを快適に使えるようにする {{{
command! -nargs=? -complete=customlist,meflib#terminal#comp  Terminal call meflib#terminal#main(<q-mods>, <f-args>)
" DOC COMMANDS Terminal
" Terminal [-term term_name] [commands]
" 
" Wrapper of terminal command.
" 
" 	[-term] is available to focus on the already opened terminal buffer.
" 	If [-term] is not specified, [commands] is available to run commands on
" 	the terminal.
" DOCEND
" }}}
" ファイルの存在チェック {{{
nnoremap <leader>f <Cmd>call meflib#filejump#main()<CR>
" DOC FUNCTIONS meflib#filejump#main()
" meflib#filejump#main()
" 
" Check the file under the cursor exists or not.
" If it starts with "http[s]", this function try to open it in the web browser.
" DOCEND
" }}}
" 行単位で差分を取る {{{
command! -nargs=+ -complete=file DiffLine call meflib#diffline#main(<f-args>)
" DOC COMMANDS DiffLine
" DiffLine {args1} {args2}
" 
" Show the difference between {args1} and {args2}.
" The format of each args is >
" 	[filename:]start_line[-end_line]
" <
" filename should be in buffer.
" start_line and end_line are number, start_line < end_line.
" DOCEND
" }}}
" 自作grep {{{
command! -nargs=? -complete=customlist,meflib#grep#comp Gregrep call meflib#grep#main(<f-args>)
" DOC COMMANDS Gregrep
" Gregrep [-wd WORD] [-dir DIR] [-ex EXT] [-all]
" 
" Wrapper of grep command.
" 	-wd: set searching strings (default: current word).
" 		<word> searches as word.
" 	-dir: set the parent directory. (default: top directory of the project
" 	of the current file or parent directory of
" 		the current file.)
" 	-ex: set the file extension (default: extension of current file).
" 		if -ex=None, no file is excluded.
" 	-all: if set, hidden directories are included to search.
" 		Hidden directories are set by "exclude_dirs" option.
" DOCEND
" }}}
" XPM test function {{{
command! XPMLoader call meflib#tools#xpm_loader()
" DOC COMMANDS XPMLoader
" XPMLoader
" 
" Test command to set highlights of xpm file.
" DOCEND
" }}}
" meflib#set された変数を表示 {{{
command! -bang -nargs=? -complete=customlist,meflib#basic#var_comp MefShowVar call meflib#basic#show_var("<bang>", <f-args>)
" DOC COMMANDS MefShowVar
" MefShowVar [var]
" 
" Show all local variables. See |meflib-options|.
" If {var} is specified, show the details of {var}.
" DOCEND
" }}}
" echo 拡張 {{{
command! -nargs=+ -complete=customlist,meflib#echo#comp Echo call meflib#echo#main(<f-args>)
" DOC COMMANDS Echo
" Echo {option}
" 
" Expand echo command. Available options are;
" 	- pand str
" 		wrapper of :echo expand("str")
" 	- env ENV
" 		echo the environmental variable with easy to seeing format.
" 	- runtime
" 		echo the runtime path.
" 	- conv10 number
" 		convert the number to decimal number.
" 	- conv8 number
" 		convert the number to octal number.
" 	- conv2 number
" 		convert the number to binary number.
" 	- conv16 number
" 		convert the number to hexadecimal number.
" 	- time time
" 		convert a integer <-> a date format.
" 		acceptable date formats are "YYYY/MM/DD" or 
" 		"YYYY/MM/DD:hh-mm-ss".
" DOCEND
" }}}
" 複数行で順に加算／減算 {{{
vnoremap <c-a><c-a> <Cmd>call meflib#ctrlax#addsub('a', 0)<CR>
vnoremap <c-a><c-x> <Cmd>call meflib#ctrlax#addsub('a', 1)<CR>
vnoremap <c-x><c-a> <Cmd>call meflib#ctrlax#addsub('x', 1)<CR>
vnoremap <c-x><c-x> <Cmd>call meflib#ctrlax#addsub('x', 0)<CR>
" }}}
" buffer を選んでtabで開く {{{
command! -bang BufOpen call meflib#openbuffer#main(<q-mods>, "<bang>")
" DOC COMMANDS BufOpen
" BufOpen[!]
" 
" Select and open a buffer.
" DOCEND
" }}}
" Buffer にコマンドの出力結果をだす {{{
command! -nargs=* -complete=customlist,meflib#cmdout#cmp CmdOut call meflib#cmdout#main(<f-args>)
" DOC COMMANDS CmdOut
" CmdOut {command}
" 
" get the output of {command} and put it in the temporary buffer.
" If {command} starts with ':', it is treated as the vim command.
" Otherwise, it is treated as the shell command.
" DOCEND
" }}}
" Jで\を消す {{{
nnoremap J <Cmd>call meflib#join_wrapper#main()<CR>
vnoremap J <Cmd>call meflib#join_wrapper#main()<CR>
" }}}
" <c-a> でtrue/falseも置換したい {{{
nnoremap <c-a> <Cmd>call meflib#ctrlax#true_false('a')<CR>
nnoremap <c-x> <Cmd>call meflib#ctrlax#true_false('x')<CR>
" }}}
" 関数一覧 {{{
command! -nargs=? -complete=customlist,meflib#tag_func_all#comp TagFuncAll call meflib#tag_func_all#open(<f-args>)
" DOC COMMANDS TagFuncAll
" TagFuncAll [option]
" 
" Show all variables/functions/etc. got from tag files.
" You select shown kinds before open the quickfix window.
" 'all' shows all items got from tag files.
" Available options are:
" 	kinds
" 		show all kinds available from this file type.
" 	tagfiles
" 		show tag files used in this command.
" DOCEND
" }}}
" quick fix list {{{
call meflib#set('map_cmds', 'Qcmds', {
            \ 'f': "call meflib#qflist#main()"
            \ })
nnoremap <leader>q <Cmd>call meflib#basic#map_util('Qcmds')<CR>
" }}}
" ちょっとpython scriptをvimで動かしたいとき {{{
command! PyTmp call meflib#pytmp#main()
" DOC COMMANDS PyTmp
" PyTmp
" 
" Open a temporary buffer to run python script.
" This python script runs when leave the insert mode.
" DOCEND
" }}}
" timer {{{
command! -nargs=1 Timer call meflib#tools#timer(<args>)
" DOC COMMANDS Timer
" Timer {sec}
" 
" set timer. After {sec} passed, message is shown and asked quit or snooze.
" 'snooze_time' is used to set the snooze time. default vaule is 600 sec (10 min).
" DOCEND
" }}}
" 自作 find {{{
command! -nargs=? -complete=customlist,meflib#find#comp Find call meflib#find#main(<f-args>)
" DOC COMMANDS Find
" Find {-name FILENAME} [-dir DIR] [-depth D]
" 
" Find files match with {FILENAME}.
" 	-name: set the searching file name (required).
" 	-dir: set the parent directory. (default: top directory of the project
" 		of the current file or parent directory of the current file.)
" 	-depth: depth of the searching files. (default: 1)
" 		-1 means to search file recursively. Otherwise, search files at the
" 		specified depth.
" DOCEND
" }}}
" 日本語（マルチバイト文字）を探索 {{{
command! SearchJa /\v[^\x01-\x7E]+
" DOC COMMANDS SearchJa
" SearchJa
" 
" Search multibyte words.
" DOCEND
" }}}

