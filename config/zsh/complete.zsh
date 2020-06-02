
# https://gist.github.com/mitukiii/4954559
# https://blog.freedom-man.com/zsh-completions
# https://qiita.com/suzuki-hoge/items/0f5851bcd84176b4f46e
_envar() {
    _values \
        'environment values' \
        $(/usr/bin/env python3 -c "import os;exec('''for k in os.environ.keys():\n    print(k+' ', end='')''')")
}

compdef _envar envar

_pip() {
    _values -w \
        'Commands' \
        "install" \
        "download" \
        "uninstall" \
        "freeze" \
        "list" \
        "show" \
        "check" \
        "config" \
        "search" \
        "cache" \
        "wheel" \
        "hash" \
        "completion" \
        "debug" \
        "help" \
}

compdef _pip pip
compdef _pip pip2
compdef _pip pip3

