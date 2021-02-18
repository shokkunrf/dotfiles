#!/bin/bash

deploy() {
  local readonly ROOT_SRC_DIRECTORY=$1

  sudo cp $ROOT_SRC_DIRECTORY/90-libinput.conf /usr/share/X11/xorg.conf.d/
}
deploy $1
