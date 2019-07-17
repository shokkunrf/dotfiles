#!/bin/bash
#
# Install snap package
install_snap(){
  local readonly SNAP_PACKAGES=(
    'go'
  )

  for package in "${SNAP_PACKAGES[@]}"; do
    sudo snap install "${package}" --classic
  done
}
install_snap
