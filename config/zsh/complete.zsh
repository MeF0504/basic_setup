
# https://gist.github.com/mitukiii/4954559
# https://blog.freedom-man.com/zsh-completions
# https://qiita.com/suzuki-hoge/items/0f5851bcd84176b4f46e

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

