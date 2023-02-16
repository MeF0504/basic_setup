
# https://gist.github.com/mitukiii/4954559
# https://blog.freedom-man.com/zsh-completions
# https://qiita.com/suzuki-hoge/items/0f5851bcd84176b4f46e
_pyviewer_cmp()
{
    _arguments \
        '(- *)'-h'[show help]' \
        -t'[type]:type:_pyviewr_types' \
        -iv'[image viewer]:image viewer:_pyviewer_iv' \
        -p'[ask pass]:pass' \
        -v'[verbose]:verbose' \
        -k'[keys]:keys' \
        -i'[interactive]:interactive' \
        -c'[interactive cui]:interactive cui' \
        --encoding'[encoding]:encoding' \
        '*:target file:_files'
}
_pyviewr_types()
{
    _values 'types' \
        'hdf5' 'pickle' 'numpy' 'tar' 'zip' 'sqlite3' 'raw_image' 'jupyter' 'xpm' 'stl'
}
_pyviewer_iv()
{
    _values 'image viewer' \
        'PIL' 'matplotlib' 'OpenCV'
}
compdef _pyviewer_cmp pyviewer

# pip zsh completion start
# https://pip.pypa.io/en/stable/user_guide/#command-completion
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] 2>/dev/null ))
}
compctl -K _pip_completion pip3
# pip zsh completion end

