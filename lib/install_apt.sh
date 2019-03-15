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
    # development
    'nodejs'
    # other
    'git'
    'ssh'
    'vim'
    'ranger'
    'mysql-server'
  )
  for package in "${NECESSARY_PACKAGES[@]}"; do
    sudo apt install -y "${package}"
  done

  # nodejs
  curl -sL https://deb.nodesource.com/setup_10.x | bash -

  sudo apt update
  for package in "${APT_PACKAGES[@]}"; do
    sudo apt install -y "${package}"
  done

}
run_apt

