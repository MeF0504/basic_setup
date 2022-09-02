
function echoenv
    echo $argv | sed -e "s/ /\\n/g"
end
