scriptencoding utf-8

""開いているファイル情報を表示（ざっくり）
function! meflib#fileinfo#main() abort
    let file = expand('%')
    if file == ''
        return
    endif
    if !has('pythonx')
        if has('win32') || has('win64')
            let s:ls = 'dir '
        else
            let s:ls='ls -l '
        endif
        execute "!" . s:ls . file
        return
    else
        pythonx << EOL
import vim
import os
try:
    import datetime
except ImportError as e:
    datetime_ok = False
else:
    datetime_ok = True

fname = vim.eval('file')
res = ''

# access
if os.access(fname, os.R_OK): res += 'r'
else: res += '-'
if os.access(fname, os.W_OK): res += 'w'
else: res += '-'
if os.access(fname, os.X_OK): res += 'x'
else: res += '-'

# time stamp
if datetime_ok:
    stat = os.stat(fname)
    # meta data update (UNIX), created (Windows)
    # dt = datetime.datetime.fromtimestamp(stat.st_ctime)
    # created (some OS)
    # dt = datetime.datetime.fromtimestamp(stat.st_birthtime)
    # last update
    dt = datetime.datetime.fromtimestamp(stat.st_mtime)
    # last access
    # dt = datetime.datetime.fromtimestamp(stat.st_atime)
    res += dt.strftime(' %Y/%m/%d-%H:%M:%S')
else:
    res += ' ????/??/??-?:?:?'

# file size
filesize = os.path.getsize(fname)
prefix = ''
if filesize > 1024**3:
    filesize /= 1024**3
    prefix = 'G'
elif filesize > 1024**2:
    filesize /= 1024**2
    prefix = 'M'
elif filesize > 1024:
    filesize /= 1024
    prefix = 'k'
res += ' ({:.1f} {}B)'.format(filesize, prefix)

# file name
res += '  '+fname
if os.path.islink(fname):
    res += ' => '+os.path.realpath(fname)

print(res)
EOL
    endif
    let words = wordcount()
    " pythonのprintはmessageに残るので，こっちもechomsgにする
    echomsg printf('characters: %d, words: %d', words['chars'], words['words'])
endfunction

