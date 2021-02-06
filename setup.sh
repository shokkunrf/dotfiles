#!/bin/bash
set -eu

DOT_DIRECTORY=`dirname $0`
LIB_DIRECTORY=$DOT_DIRECTORY/lib
SRC_DIRECTORY=$DOT_DIRECTORY/src

setup(){
  bash $LIB_DIRECTORY/deploy.sh $SRC_DIRECTORY

  case $OSTYPE in
    linux-gnu)
      bash $DOT_DIRECTORY/lib/install_apt.sh
      exec $SHELL -l
      bash $DOT_DIRECTORY/lib/install_bin.sh 'golang' 'git-prompt'
      bash $DOT_DIRECTORY/lib/install_goget.sh
      ;;
    *)
      echo $(tput setaf 1)Working only Debian!$(tput sgr0)
      exit 1
      ;;
  esac

  bash $DOT_DIRECTORY/lib/init.sh
} >/dev/null
setup
