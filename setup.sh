#!/bin/bash
# 
# dotfiles utils

set -eu
DOT_DIRECTORY="${HOME}/dotfiles"

usage() {
  name=`basename $0`
  cat <<EOF
Usage:
  $name [command]
Commands:
  setup      - setup all
  deploy     - link symbolic link
  download   - download dotfiles to HOME
  initialize - initialize
  install    - install packages by apt

EOF
  exit 1
}

#########################
# Symbolink
# Globals:
#   DOT_DIRECTORY
# Arguments:
#   None
# Return:
#   None
#########################
deploy_dotfiles(){
  if [ ! -d "${DOT_DIRECTORY}" ] ; then
    echo "$(tput setaf 1)** warning **dotfiles does not exist!$(tput sgr0)"
    echo "${DOT_DIRECTORY}"
  else 
    source "${DOT_DIRECTORY}/lib/deploy.sh" "${DOT_DIRECTORY}" 
  fi
}

#########################
# Install packages
# Globals:
#   OSTYPE
#   DOT_DIRECTORY
# Arguments:
#   None
# Return:
#   None
#########################
install_packages(){
  case "${OSTYPE}" in
    linux-gnu)
      source "${DOT_DIRECTORY}/lib/install_apt.sh"
      source "${DOT_DIRECTORY}/lib/install_snap.sh"
      ;;
    *)
      echo $(tput setaf 1)Working only Debian!$(tput sgr0)
      exit 1
      ;;
  esac
}

#########################
# Initialize something
# Globals:
#   DOT_DIRECTORY
# Arguments:
#   None
# Return:
#   None
#########################
initialize_dotfiles(){
  if [ ! -d "${DOT_DIRECTORY}" ] ; then
    echo "$(tput setaf 1)** warning **dotfiles does not exist!$(tput sgr0)"
    echo "${DOT_DIRECTORY}"
  else 
    source "${DOT_DIRECTORY}/lib/init.sh"
  fi
}

if [ "$#" = 0 ] ;then
  SUBCOMMAND="0"
else
  SUBCOMMAND="$1"
fi

case "$SUBCOMMAND" in
  setup)
    install_packages && \
    deploy_dotfiles
    initialize_dotfiles
    ;;
  deploy)
    deploy_dotfiles
    ;;
  init*)
    initialize_dotfiles
    ;;
  install)
    install_packages
    ;;
  *)
    usage
    ;;
esac

exit 0
