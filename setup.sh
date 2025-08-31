#!/bin/bash
set -eu

DOT_DIRECTORY="$(cd $(dirname $0) && pwd)"
LIB_DIRECTORY=$DOT_DIRECTORY/lib

with_gui=false
case $@ in
  --with-gui)
    with_gui=true
    ;;
  *)
    ;;
esac

setup(){
  case $OSTYPE in
    linux-gnu)
      local readonly APT_CUI_PACKAGES=(
        'vim'
        'peco'
        'jq'
        'wget'
        'curl'
        'git'
        'sudo'
      )
      apt update
      apt install -y ${APT_CUI_PACKAGES[@]}

      local readonly EX_CUI_PACKAGES=(
        'docker'
      )
      $LIB_DIRECTORY/install_ex.sh ${EX_CUI_PACKAGES[@]}

      if $with_gui; then
        local readonly APT_GUI_PACKAGES=(
          # terminal
          'qterminal'
          'adwaita-qt'
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
          # input
          'xinput'
          # notice
          'libnotify-bin'
          'dunst'
          # audio
          'alsa-utils'
          'pavucontrol'
          # backlight
          'brightnessctl'
        )
        apt install -y ${APT_GUI_PACKAGES[@]}

        local readonly EX_GUI_PACKAGES=(
          'chrome'
          'vscode'
        )
        $LIB_DIRECTORY/install_ex.sh ${EX_GUI_PACKAGES[@]}
      fi
      ;;
    *)
      echo 'Only works on Debian!' >&2
      exit 1
      ;;
  esac
}
setup
