scriptencoding utf-8
py3file <sfile>:h/git_status.py

" gitのbranchと最終更新日時を表示
let s:git_pid = -1
let s:git_bid = -1
let g:meflib#git_status#branch = ""
let g:meflib#git_status#date = ""
let g:meflib#git_status#pre_merge = 0
let g:meflib#git_status#pre_push = 0

function! meflib#git_status#update_info() abort
    if empty(finddir('.git', ';'))
        let g:meflib#git_status#branch = ""
        let g:meflib#git_status#date = ""
        let g:meflib#git_status#pre_merge = 0
        let g:meflib#git_status#pre_push = 0
        return
    endif

    python3 set_branch()
    python3 set_update_date()
    python3 set_unmerged_commits()
    python3 set_unpushed_commits()
endfunction
call meflib#git_status#update_info()

function! meflib#git_status#main() abort
    if empty(finddir('.git', ';'))
        return
    endif

    let print_str = printf("%s(m%d|p%d) %s",
                \ g:meflib#git_status#branch,
                \ g:meflib#git_status#pre_merge,
                \ g:meflib#git_status#pre_push,
                \ g:meflib#git_status#date)
    " echo print_str
    let config = {
                \ 'relative': 'editor',
                \ 'line': 3,
                \ 'col': &columns,
                \ 'pos': 'botright',
                \ 'highlight': 'GitStatusLocal',
                \ 'zindex': 35,
                \ }
    let [s:git_bid, s:git_pid] = meflib#floating#open(s:git_bid, s:git_pid,
                \ [print_str], config
                \ )
endfunction

function! meflib#git_status#clear() abort
    call meflib#floating#close(s:git_pid)
    let s:git_pid = -1
endfunction

