from datetime import datetime
import subprocess
import vim

branch = None


def set_branch():
    global branch
    cmd = 'git branch --contains'.split()
    res = subprocess.run(cmd, capture_output=True)
    if len(res.stdout) > 0:
        # show error.
        vim.command('let g:meflib#git_status#branch = ""')
        branch = None

    branch = (res.stdout.decode()).split()[1]
    vim.command(f'let g:meflib#git_status#branch = "{branch}"')


def set_update_date():
    cmd = ['git', 'log', '--date=iso',
           '--date=format:%Y/%m/%d', '--pretty=format:%ad', '-1']
    res = subprocess.run(cmd, capture_output=True)
    if len(res.stdout) > 0:
        # show error.
        vim.command('let g:meflib#git_status#date = "-/-"')

    date = res.stdout.decode()
    if str(datetime.today().year) == date[:4]:
        date = date[5:]
        vim.command(f'let g:meflib#git_status#date = "{date}"')


def check_remote_branch_exists():
    if branch is None:
        return False
    remote = f'origin/{branch}'
    cmd = 'git branch --remotes'.split()
    res = subprocess.run(cmd, capture_output=True)
    if len(res.stdout) > 0:
        return False

    if remote in res.stdout.decode():
        return True
    else:
        return False


def set_unmerged_commits():
    if branch is None:
        vim.command('let g:meflib#git_status#pre_merge = 0')
        return

    if not check_remote_branch_exists():
        vim.command('let g:meflib#git_status#pre_merge = 0')
        return

    cmd = ['git', 'log', '--oneline', f'HEAD..origin/f{branch}']
    res = subprocess.run(cmd, capture_output=True)
    if len(res.stdout) > 0:
        vim.command('let g:meflib#git_status#pre_merge = 0')
        return
    else:
        num_cmts = len((res.stdout.decode()).split('\n'))
        vim.command(f'let g:meflib#git_status#pre_merge = {num_cmts}')


def set_unpushed_commits():
    if branch is None:
        vim.command('let g:meflib#git_status#pre_push = 0')
        return

    if not check_remote_branch_exists():
        vim.command('let g:meflib#git_status#pre_push = 0')
        return

    cmd = ['git', 'rev-list', f'origin/f{branch}..f{branch}']
    res = subprocess.run(cmd, capture_output=True)
    if len(res.stdout) > 0:
        vim.command('let g:meflib#git_status#pre_push = 0')
        return
    else:
        num_cmts = len((res.stdout.decode()).split('\n'))
        vim.command(f'let g:meflib#git_status#pre_push = {num_cmts}')
