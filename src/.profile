#!/bin/sh

# Homebrew (macOS)
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$brew" ]; then
    eval "$("$brew" shellenv)"
    break
  fi
done
unset brew

export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/bin
