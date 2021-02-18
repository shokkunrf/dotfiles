#!/bin/bash
set -eu

ARGS=$@

is_contained() {
  return $(echo $ARGS | grep -sq $1)
}

install() {
  if $(is_contained 'git-prompt'); then
    wget -O ~/.git-prompt.sh 'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh'
  fi
  if $(is_contained 'vbox-guest-addtion'); then
    sudo apt install -y linux-headers-amd64
    sudo mount /dev/sr0 /media/cdrom
    sudo bash /media/cdrom0/VBoxLinuxAdditions.run
  fi
  if $(is_contained 'docker'); then
    # docker engine
    sudo apt -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io
    # docker-compose
    tag=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/docker/compose/releases/latest \
      | jq -r '.name')
    sudo curl -L https://github.com/docker/compose/releases/download/$tag/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi
  if $(is_contained 'chrome'); then
    wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./chrome.deb
    rm ./chrome.deb
  fi
  if $(is_contained 'vscode'); then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > ./microsoft.gpg
    sudo install -o root -g root -m 644 ./microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install code
    rm ./microsoft.gpg
  fi
  if $(is_contained 'nvidia-driver'); then
    # Install NvidiaGraphicsDrivers for Debian9
    sudo bash -c "echo 'deb http://httpredir.debian.org/debian/ stretch main contrib non-free' >> /etc/apt/sources.list"

    sudo apt update
    sudo apt install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver

    echo "Please reboot"
  fi
}
install
