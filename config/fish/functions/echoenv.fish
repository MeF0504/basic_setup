
function echoenv --description 'display environmental value smartly'
    echo $argv | sed -e "s/ \//\\n\//g"
end
