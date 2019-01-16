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
  )
  cd "${DOT_DIRECTORY}"

  echo "link start..."
  for file in "${LINK_LIST[@]}"; do
    ln -sv "${DOT_DIRECTORY}/${file}" "${HOME}/${file}"
  done
  echo "$(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)"
}
symbolink "$1"
