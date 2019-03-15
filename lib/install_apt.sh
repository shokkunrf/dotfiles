#!/bin/bash
#
# Install package apt

run_apt(){
  local readonly NECESSARY_PACKAGES=(
    # first
    'curl'
    'wget'
    'build-essential'
  )

  local readonly APT_PACKAGES=(
    # terminal
    'rxvt-unicode-256color'
    # langage
    'fcitx-mozc'
    # GUI
    'xorg'
    'firefox-esr'
    # xmonad
    'xmonad'
    'xmobar'
    'dmenu'
    'feh'
    'xinput'
    # notice
    'libnotify-bin'
    'dunst'
    # sound
    'alsa-utils'
    'pavucontrol'
    # other
    'ssh'
    'vim'
    'ranger'
    'mysql-server'
  )
  for package in "${NECESSARY_PACKAGES[@]}"; do
    sudo apt install -y "${package}"
  done

  sudo apt update
  for package in "${APT_PACKAGES[@]}"; do
    sudo apt install -y "${package}"
  done

}
run_apt

