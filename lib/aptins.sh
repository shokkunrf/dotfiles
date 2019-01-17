#!/bin/bash
#
# Install package apt

run_apt(){
  local readonly packagelist=(
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
    'build-essential'
    'nodejs'
    # other
    'git'
    'ssh'
    'vim'
    'curl'
    'wget'
    'ranger'
    'mysql-server'
  )

  # nodejs
  curl -sL https://deb.nodesource.com/setup_10.x | bash -

  echo "start apt install..."
  for item in "${packagelist[@]}"; do
    apt install -y "${item}"
  done
  echo "finished apt install"

  apt update
  apt upgrade
}
run_apt

