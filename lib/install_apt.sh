#!/bin/bash
#
# Install apt package

run_apt(){
  local readonly NECESSARY_PACKAGES=(
    # first
    'curl'
    'wget'
    'build-essential'
    'apt-transport-https'
    'ca-certificates'
    'gnupg2'
    'software-properties-common'
    'snapd'
    'python3-pip'
  )

  local readonly APT_PACKAGES=(
    # terminal
    'rxvt-unicode-256color'
    # langage
    'fcitx-mozc'
    # GUI
    'gnome'
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
    'wmctrl'
    # PPA
    'code'
    'google-chrome-stable'
    'docker-ce'
    'docker-ce-cli'
    'containerd.io'
    'virtualbox-6.0'
  )

  for package in "${NECESSARY_PACKAGES[@]}"; do
    sudo apt install -y "${package}"
  done

  # chrome
  curl https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'
  # vscode
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  # docker
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  # VirtualBox
  curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -
  sudo add-apt-repository "deb https://download.virtualbox.org/virtualbox/debian stretch contrib"

  # slack
  wget -O slack.deb  'https://downloads.slack-edge.com/linux_releases/slack-desktop-3.4.2-amd64.deb'
  sudo apt install -y ./slack.deb
  rm slack.deb
  # Vagrant
  wget -O vagrant.deb "https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.deb"
  sudo apt install -y ./vagrant.deb
  rm vagrant.deb

  sudo apt update
  for package in "${APT_PACKAGES[@]}"; do
    sudo apt install -y "${package}"
  done

}
run_apt

