#!/bin/zsh

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

