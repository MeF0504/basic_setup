
# {{{ grep
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
# }}}

# {{{ pytree
function _pytree_comp()
{
    _arguments \
        '(- *)'{-h,--help}'[show help]' \
        -a'[do not ignore entries starting with .]' \
        '(-v --verbose)'{-v,--verbose}'[show the verbose.]' \
        -maxdepth'[specify the level of directory. If set 0, show all directories.]' \
        -exclude'[specify excluding patterns using regular expression.]' \
        -exfiles'[specify excluding patterns from pattern files written in shell]:exfiles:_files' \
        '*:target dir:_dirs'
}
compdef _pytree_comp pytree
# }}}

# {{{ copy_util
function _copy_util_comp()
{
    _arguments \
        '(- *)'{-h,--help}'[show help]' \
        --cmp'[compare each file and skip copy if files are same.]' \
        '(-r --recursive)'--date'[copy files in the source directory to target_dir/{date}.]' \
        '(-r --recursive -c -b -m -a --date)'{-r,--recursive}'[copy files recursively.]' \
        '(-r --recursive)'-c'[date option: meta data update (UNIX), created (Windows)]' \
        '(-r --recursive)'-b'[date option: created (some OS)]' \
        '(-r --recursive)'-m'[date option: last update]' \
        '(-r --recursive)'-a'[date option: last access]' \
        '*:target file:_files'

}
compdef _copy_util_comp copy_util.py
# }}}

# {{{ pip
# https://pip.pypa.io/en/stable/user_guide/#command-completion

# pip zsh completion start
#compdef -P pip[0-9.]#
__pip() {
  compadd $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$((CURRENT-1)) \
             PIP_AUTO_COMPLETE=1 $words[1] 2>/dev/null )
}
if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
  # autoload from fpath, call function directly
  __pip "$@"
else
  # eval/source/. command, register function for later
  compdef __pip -P 'pip[0-9.]#'
fi
# pip zsh completion end
# }}}

