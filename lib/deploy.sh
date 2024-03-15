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

ln -sf ~/Repositories/dotfiles/src/.config/Code/User/keybindings_mac.json  ~/Library/Application\ Support/Code/User/keybindings.json
ln -sf ~/Repositories/dotfiles/src/.config/Code/User/settings.json  ~/Library/Application\ Support/Code/User/settings.json
}
deploy $1
