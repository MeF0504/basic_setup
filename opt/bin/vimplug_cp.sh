for dir in plugin autoload colors doc
do
    echo $dir
    if [[ -d "./${dir}" ]]; then
        echo "copy ./${dir}"
        if [[ ! -d "${HOME}/.vim/test/${dir}" ]]; then
            mkdir ${HOME}/.vim/test/${dir}
        fi
        cp -r ./${dir}/* ${HOME}/.vim/test/${dir}
    fi
done
