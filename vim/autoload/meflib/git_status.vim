scriptencoding utf-8

" gitのbranchと最終更新日時を表示
let s:git_pid = -1
let s:git_bid = -1
function! meflib#git_status#main() abort
    if empty(finddir('.git', ';'))
        return
    endif
    " branch
    let cmd = ['git', 'branch', '--contains']
    if !has('nvim')
        let cmd = join(cmd)
    endif
    let branch = systemlist(cmd)[0][2:]

    " latest update date
    if has('nvim')
        let cmd = ['git', 'log', '--date=iso', '--date=format:%Y/%m/%d',
                \ '--pretty=format:%ad', '-1']
    else
        let cmd = join(['git', 'log', '--date=iso', '--date=format:"%Y/%m/%d"',
                \ '--pretty=format:"%ad"', '-1'])
    endif
    let date = system(cmd)

    " number of unmerged commits
    let cmd = ['git', 'log', '--oneline', printf('HEAD..origin/%s', branch)]
    if !has('nvim')
        let cmd = join(cmd)
    endif
    let pre_merge = len(systemlist(cmd))

    " number of unpushed commits
    let cmd = ['git', 'rev-list', printf('origin/%s..%s', branch, branch)]
    if !has('nvim')
        let cmd = join(cmd)
    endif
    let pre_push = len(systemlist(cmd))

    let print_str = printf("%s(m%d|p%d) %s", branch, pre_merge, pre_push, date)
    " echo print_str
    let config = {
                \ 'relative': 'editor',
                \ 'line': &lines-&cmdheight-1,
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

