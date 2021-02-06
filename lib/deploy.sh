#!/bin/bash

deploy() {
  local readonly SRC_DIRECTORY=$1
  local readonly FILES=(
    'bin'
    '.config'
    'mixin'
    '.vimrc'
    '.xinitrc'
    '.Xmodmap'
    '.xmonad'
    '.zprofile'
    '.zsh_aliases'
    '.zshrc'
  )

  for file in "${FILES[@]}"; do
    ln -s "$SRC_DIRECTORY/$file" "$HOME/"
  done
}
deploy $1
