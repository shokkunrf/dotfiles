#!/bin/bash

if [ -f ~/.profile ]; then
  # shellcheck source=src/.profile
  . ~/.profile
fi

if [ -f ~/.bashrc ]; then
  # shellcheck source=src/.bashrc
  . ~/.bashrc
fi
