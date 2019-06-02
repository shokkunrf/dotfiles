#!/bin/bash

sudo pip3 install xonsh
run_pip3(){
  local readonly PACKAGES=(
    'xonsh'
    'ptpython'
  )
  for package in "${PACKAGES[@]}"; do
    sudo pip3 install "${package}"
  done
}

run_pip3