
function load_venv()
{
    if [[ $TERM_PROGRAM = "vscode" ]]; then
        # VSCode の場合はとりあえず無視
        return
    fi
    local venv_dir=$(find . -maxdepth 1 -type d -name ".venv*" | head -n 1)
    if [[ -d $venv_dir ]]; then
        # .venvがある場合は仮想環境を有効化する
        if [[ -f "$venv_dir/bin/activate" ]]; then
            if which deactivate > /dev/null 2>&1; then
                echo "deactivate current venv"
                deactivate
            fi
            source "$venv_dir/bin/activate"
        elif [[ -f "$venv_dir/Scripts/activate" ]]; then
            if which deactivate > /dev/null 2>&1; then
                echo "deactivate current venv"
                deactivate
            fi
            source "$venv_dir/Scripts/activate"
        fi
    fi
}
