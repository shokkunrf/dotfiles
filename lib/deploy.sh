#!/bin/bash
# 
# Create symbolick link

#########################
# Create symbolick link
# Globals:
#   None
# Arguments:
#   DOT_DIRECTORY
# Return:
#   None
#########################
symbolink(){
  local readonly DOT_DIRECTORY="$1"
  local readonly LINK_LIST=(
    '.bash_aliases'
    '.bash_profile'
    '.bashrc'
    '.Xmodmap'
    '.Xresources'
    '.vimrc'
    'bin'
    '.xmonad'
  )
  cd "${DOT_DIRECTORY}"

  for file in "${LINK_LIST[@]}"; do
    ln -s "${DOT_DIRECTORY}/${file}" "${HOME}/${file}"
  done
}
symbolink "$1"
