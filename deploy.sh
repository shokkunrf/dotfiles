#!/bin/bash
set -eu

DOT_DIRECTORY="$(cd $(dirname $0) && pwd)"
SRC_DIRECTORY=$DOT_DIRECTORY/src

with_gui=false
case $@ in
  --with-gui)
    with_gui=true
    ;;
  *)
    ;;
esac

deploy(){
  git config --global alias.st status
  git config --global alias.br branch
  git config --global alias.ch checkout
  git config --global alias.ad add
  git config --global alias.cm commit

  local readonly CUI_FILES=(
    'bin'
    '.bashrc'
    '.profile'
    '.vimrc'
  )
  for file in ${CUI_FILES[@]} ; do
    ln -sfn $SRC_DIRECTORY/$file $HOME/$file
  done

  if $with_gui; then
    local readonly GUI_FILES=(
      '.config/qterminal.org'
      '.Xmodmap'
      '.xmonad'
      '.xsession'
    )
    for file in ${GUI_FILES[@]} ; do
      ln -sfn $SRC_DIRECTORY/$file $HOME/$file
    done
  fi

  case $OSTYPE in
    linux-gnu)
    ;;
    Darwin)
      # Dockを自動的に隠す
      defaults write com.apple.dock autohide -bool false
      # タップでクリックを許可
      defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
      # カーソルの移動速度を変更 (1-15)
      defaults write -g com.apple.trackpad.scaling -float 15
      # Finder: 隠しファイル表示
      defaults write com.apple.finder AppleShowAllFile true
      # Finder: 拡張子表示
      defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    ;;
    *)
    ;;
  esac
}
deploy
