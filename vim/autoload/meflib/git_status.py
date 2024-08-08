from datetime import datetime
import subprocess
import vim

branch = None


def is_err(res):
    if len(res.stderr) > 0:
        print(f'[git-staus error]: {res.stderr.decode()}')
        return True
    else:
        return False


def set_branch():
    global branch
    cmd = 'git branch --contains'.split()
    res = subprocess.run(cmd, capture_output=True)
    if is_err(res):
        vim.command('let g:meflib#git_status#branch = ""')
        branch = None
        return

    for b in (res.stdout.decode()).splitlines():
        if b.startswith('* '):
            branch = b[2:]
    vim.command(f'let g:meflib#git_status#branch = "{branch}"')


def set_update_date():
    cmd = ['git', 'log', '--date=iso',
           '--date=format:%Y/%m/%d', '--pretty=format:%ad', '-1']
    res = subprocess.run(cmd, capture_output=True)
    if is_err(res):
        vim.command('let g:meflib#git_status#date = "-/-"')
        return

    date = res.stdout.decode()
    date = date.replace('\n', '')
    if str(datetime.today().year) == date[:4]:
        date = date[5:]
        vim.command(f'let g:meflib#git_status#date = "{date}"')


def check_remote_branch_exists():
    if branch is None:
        return False
    remote = f'origin/{branch}'
    cmd = 'git branch --remotes'.split()
    res = subprocess.run(cmd, capture_output=True)
    if is_err(res):
        return False

    if remote in res.stdout.decode():
        return True
    else:
        return False


def set_unmerged_commits():
    # HEADからこのbranchがいくつ遅れているか
    if branch is None:
        vim.command('let g:meflib#git_status#pre_merge = -1')
        return

    if not check_remote_branch_exists():
        vim.command('let g:meflib#git_status#pre_merge = -1')
        return

    cmd = ['git', 'log', '--oneline', f'HEAD..origin/{branch}']
    res = subprocess.run(cmd, capture_output=True)
    if is_err(res):
        vim.command('let g:meflib#git_status#pre_merge = -1')
        return
    else:
        if len(res.stdout) == 0:
            num_cmts = 0
        else:
            num_cmts = len((res.stdout.decode()).split('\n'))
        vim.command(f'let g:meflib#git_status#pre_merge = {num_cmts}')


def set_unpushed_commits():
    # remote にpushしていないコミット数
    if branch is None:
        vim.command('let g:meflib#git_status#pre_push = -1')
        return

    if not check_remote_branch_exists():
        vim.command('let g:meflib#git_status#pre_push = -1')
        return

    cmd = ['git', 'rev-list', f'origin/{branch}..{branch}']
    res = subprocess.run(cmd, capture_output=True)
    if is_err(res):
        vim.command('let g:meflib#git_status#pre_push = -1')
        return
    else:
        if len(res.stdout) == 0:
            num_cmts = 0
        else:
            num_cmts = len((res.stdout.decode()).split('\n'))
        vim.command(f'let g:meflib#git_status#pre_push = {num_cmts}')
