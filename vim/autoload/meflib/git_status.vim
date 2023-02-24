scriptencoding utf-8

" gitのbranchと最終更新日時を表示
let s:git_pid = -1
let s:git_bid = -1
function! meflib#git_status#main() abort
    if empty(finddir('.git'))
        return
    endif
    let b_cmd = ['git', 'branch', '--contains']
    if !has('nvim')
        let b_cmd = join(b_cmd)
    endif
    let branch = system(b_cmd)[2:]
    if has('nvim')
        let d_cmd = ['git', 'log', '--date=iso', '--date=format:%Y/%m/%d',
                \ '--pretty=format:%ad', '-1']
    else
        let d_cmd = join(['git', 'log', '--date=iso', '--date=format:"%Y/%m/%d"',
                \ '--pretty=format:"%ad"', '-1'])
    endif
    let date = system(d_cmd)
    let print_str = printf("%s:%s", branch, date)->substitute('\n', '', '')
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

