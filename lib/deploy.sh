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
  cd "${DOT_DIRECTORY}"

  echo "link start..."
  for file in .??*; do
    [ "${file}" = ".git" ] && continue
    [ "${file}" = ".gitignore" ] && continue

    ln -sv "${DOT_DIRECTORY}/${file}" "${HOME}/${file}" || \
      echo "err ${file}"
  done
  echo "$(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)"
}
symbolink "$1"
