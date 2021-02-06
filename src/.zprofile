#!/bin/zsh
# zsh profile

# mixin
. $HOME/mixin/.shell_profile

# zsh
if [ -n "$ZSH_VERSION" ]; then
  if [ -f "$HOME/.zsh_aliases" ]; then
    . $HOME/.zsh_aliases
  fi
  if [ -f "$HOME/.zshrc" ]; then
    . $HOME/.zshrc
  fi
fi

export PATH=$PATH:/usr/local/go/bin
