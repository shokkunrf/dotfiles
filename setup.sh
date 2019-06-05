#!/bin/bash
set -eu

DOT_DIRECTORY=`dirname $0`

setup(){
  . "${DOT_DIRECTORY}/lib/deploy.sh"

  case "${OSTYPE}" in
    linux-gnu)
      . "${DOT_DIRECTORY}/lib/install_apt.sh"
      exec $SHELL -l
      . "${DOT_DIRECTORY}/lib/install_snap.sh"
      . "${DOT_DIRECTORY}/lib/install_goget.sh"
      . "${DOT_DIRECTORY}/lib/install_pip3.sh"
      . "${DOT_DIRECTORY}/lib/install_bin.sh"
      ;;
    *)
      echo $(tput setaf 1)Working only Debian!$(tput sgr0)
      exit 1
      ;;
  esac

  . "${DOT_DIRECTORY}/lib/init.sh"
} >/dev/null
setup
