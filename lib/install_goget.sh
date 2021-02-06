#!/bin/bash

install_golang(){
  wget -O golang.tar.gz https://golang.org/dl/go1.15.8.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf golang.tar.gz
  rm golang.tar.gz
}

run_goget(){
  local readonly PACKAGES=(
    'github.com/google/skicka'
    'github.com/pocke/xrandr-mirror'
  )
  for package in "${PACKAGES[@]}"; do
    go get "${package}"
  done
}

install_golang
export PATH=$PATH:/usr/local/go/bin
run_goget
