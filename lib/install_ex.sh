#!/bin/bash
set -eu

ARGS=$@

is_contained() {
  return $(echo $ARGS | grep -sq $1)
}

install_ex() {
  if $(is_contained 'docker'); then
    # https://docs.docker.com/engine/install/debian/#install-using-the-repository
    apt update
    apt install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    if [ $SUDO_USER ]; then
      gpasswd -a $SUDO_USER docker
    else
      gpasswd -a $USER docker
    fi
  fi
  if $(is_contained 'chrome'); then
    curl -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -y /tmp/chrome.deb
    rm /tmp/chrome.deb
  fi
  if $(is_contained 'vscode'); then
    curl -L -o /tmp/vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
    apt install -y gpg /tmp/vscode.deb
    rm /tmp/vscode.deb
  fi
}
install_ex
