#!/bin/bash
#
# thanks to https://gist.github.com/956095.git

# (1) copy to: ~/bin/ssh-host-color 
# (2) set:     alias ssh=~/bin/ssh-host-color
#
# Inspired from http://talkfast.org/2011/01/10/ssh-host-color
# Fork from https://gist.github.com/773849
#

set_term_bgcolor(){
  local R=$1
  local G=$2
  local B=$3
  /usr/bin/osascript <<EOF
tell application "iTerm"
  tell the current terminal
    tell the current session
      set background color to {$(($R*65535/255)), $(($G*65535/255)), $(($B*65535/255))}
    end tell
  end tell
end tell
EOF
}

trap 'set_term_bgcolor 0 0 0' 2
#return background color if ssh canceled by Ctr-C

if [[ "$@" =~ coma ]]; then
  set_term_bgcolor 0 0 20
elif [[ "$@" =~ kekcc ]]; then
  set_term_bgcolor 0 20 15
elif [[ "$@" =~ nersc ]]; then
  set_term_bgcolor 0 20 15
elif [[ "$@" =~ gt ]]; then
  set_term_bgcolor 20 10 0
fi

ssh $@

set_term_bgcolor 0 0 0
