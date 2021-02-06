#!/bin/bash

install() {
  local readonly PACKAGES=(
    # terminal
    'xterm'
    'qterminal'
    # font
    'fonts-noto-color-emoji'
    'fonts-ipafont-mincho'
    'fcitx-mozc'
    # xmonad
    'xorg'
    'xmonad'
    'xmobar'
    'dmenu'
    'feh'
    # tools
    'firefox-esr'
    'vim'
    'peco'
    'jq'
    'zsh'
    'wget'
    'curl'
    'build-essential'
    # input
    'xinput'
    # notice
    'libnotify-bin'
    'dunst'
    # sound
    'alsa-utils'
    'pavucontrol'
  )
  sudo apt install -y ${PACKAGES[@]}
}
install
