#!/bin/bash

run_goget(){
  local readonly PACKAGES=(
    'github.com/google/skicka'
    'github.com/motemen/ghq'
    'github.com/pocke/xrandr-mirror'
  )
  for package in "${PACKAGES[@]}"; do
    go get "${package}"
  done
}

run_goget
