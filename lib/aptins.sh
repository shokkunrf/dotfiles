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
    # other
    'git'
    'ssh'
    'vim'
    'curl'
    'wget'
    'ranger'
  )
  echo "start apt install..."
  for item in "${packagelist[@]}"; do
    sudo apt install -y "${item}"
  done
  echo "finished apt install"

  sudo apt update
  sudo apt upgrade
}
run_apt

