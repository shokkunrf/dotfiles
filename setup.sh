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
# Download dotfiles
# Globals:
#   DOT_DIRECTORY
# Arguments:
#   None 
# Returns:
#   None
#########################
download_dotfiles(){
  if [ -d "${DOT_DIRECTORY}" ] ; then
    echo "$(tput setaf 1)** warning **dotfiles already exists!$(tput sgr0)"
    echo "${DOT_DIRECTORY}"
  else
#   read -p 'github name: ' user
    user='uekyorf'
    local DOT_TARBALL="https://github.com/${user}/dotfiles/tarball/master"
    local REMOTE_URL="git@github.com:${user}/dotfiles.git"

   echo 'Downloading dotfiles...'
    mkdir "${DOT_DIRECTORY}"

    # if has "git"; then
    if type "git" > /dev/null 2>&1 ; then
      git clone --recursive "${REMOTE_URL}" "${DOT_DIRECTORY}"
    else
      curl -fsSLo ${HOME}/dotfiles.tar.gz ${DOT_TARBALL}
      tar -zxf ${HOME}/dotfiles.tar.gz --strip-components 1 -C ${DOT_DIRECTORY}
      rm -f ${HOME}/dotfiles.tar.gz
    fi
    echo "$(tput setaf 2)Download dotfiles complete!. ✔︎$(tput sgr0)"
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
      source "${DOT_DIRECTORY}/lib/aptins.sh"
      ;;
    *)
      echo $(tput setaf 1)Working only Debian!$(tput sgr0)
      exit 1
      ;;
  esac
}

if [ "$#" = 0 ] ;then
  SUBCOMMAND="0"
else
  SUBCOMMAND="$1"
fi

case "$SUBCOMMAND" in
  setup)
    download_dotfiles && \
    install_packages && \
    deploy_dotfiles
    # initialize_dotfiles
    ;;
  deploy)
    deploy_dotfiles
    ;;
  download)
    download_dotfiles
    ;;
  init*)
    # initialize_dotfiles
    ;;
  install)
    install_packages
    ;;
  *)
    usage
    ;;
esac

exit 0
