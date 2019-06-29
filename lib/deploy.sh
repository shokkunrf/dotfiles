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
  local readonly DOT_DIRECTORY=`dirname $0`/..
  local readonly LINK_LIST=(
    '.profile'
    '.bash_aliases'
    '.bashrc'
    '.Xmodmap'
    '.Xresources'
    '.vimrc'
    'bin'
    '.xmonad'
  )

  for file in "${LINK_LIST[@]}"; do
    ln -s "${DOT_DIRECTORY}/${file}" "${HOME}/"
  done
}
symbolink
