#!/bin/bash
#
# Install package apt

run_apt(){
  local readonly packagelist=(
    # terminal
    'xterm'
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
    'libnotify-bin'
    'dunst'
    'xinput'
    # other
    'git'
    'ssh'
    'vim'
    'build-essential'
    'curl'
    'wget'
    'ranger'
    'pavucontrol'
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

