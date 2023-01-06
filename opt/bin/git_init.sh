#! /bin/bash

read -p "init here? (y/[n])" YN

if [[ "${YN}" = "y" ]]; then
    git init
    case "$(uname)" in
        Darwin*)
            open https://github.com/new
            ;;
        Linux*)
            xdg-open https://github.com/new
            ;;
        *)
            echo 'please open https://github.com/new'
            ;;
    esac

    read -p "paste remote ssh URL here; " URL
    git remote add origin $URL
    echo "fetching..."
    git fetch
    echo "merging..."
    git merge origin/main
    echo "staging..."
    git add .
    read -p "commit & push? (please check the above list) (y/[n])" YN
    if [[ "${YN}" = "y" ]]; then
        git commit -m 'first commit'
        git push --set-upstream origin main
        git checkout -b develop origin/develop
    fi
fi

