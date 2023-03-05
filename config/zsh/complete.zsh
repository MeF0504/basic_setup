
function _grep_comp()
{
    _arguments \
        '(- *)'--help'[show help]' \
        '(- *)'{-V,--version}'[print the version]' \
        -n'[line number]' \
        -r'[Read all files under each directory recursively]' \
        -i'[Ignore case distinctions]' \
        -I'[Ignore binary files]' \
        -l'[Print only file names.]' \
        -m'[Stop reading a file after NUM matching lines.]' \
        -A'[Print NUM lines after matching lines.]' \
        -B'[Print NUM lines before matching lines.]' \
        --exclude='[Skip files whose base name matches GLOB.]' \
        --exclude-dir='[Exclude directories matching the pattern DIR from recursive searches.]' \
        --include='[Search only files whose base name matches GLOB.]' \
        '2:patterns:' \
        '3:targets:_files'
}
compdef _grep_comp grep


# pip zsh completion start
# https://pip.pypa.io/en/stable/user_guide/#command-completion
function _pip_completion
{
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] 2>/dev/null ))
}
compctl -K _pip_completion pip3
# pip zsh completion end

