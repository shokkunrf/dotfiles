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
  local readonly linkList=(
    '.bash_aliases'
    '.bash_profile'
    '.bashrc'
    '.Xmodmap'
    '.Xresources'
    '.vimrc'
    'bin'
  )
  cd "${DOT_DIRECTORY}"

  echo "link start..."
  for file in linkList; do
    ln -sv "${DOT_DIRECTORY}/${file}" "${HOME}/${file}"
  done
  echo "$(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)"
}
symbolink "$1"
