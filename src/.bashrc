#!/bin/bash

# 対話シェル以外では何もしない
case $- in
  *i*) ;;
  *) return ;;
esac

if [ -f "$HOME/.shrc" ]; then
  # shellcheck source=src/.shrc
  . "$HOME/.shrc"
fi

shopt -s histappend
HISTCONTROL=ignoredups
HISTFILE=$HOME/.shell_history
HISTSIZE=2000
HISTFILESIZE=100000

shopt -s checkwinsize
shopt -s globstar

RED="\e[31m"
GREEN="\e[32m"
BOLD_BLUE="\e[1;34m"
RESET="\e[0m"
myps1() {
  local char_limit=3
  local dir_path short_path
  dir_path=$(pwd | sed "s@${HOME}@~@")
  short_path=$(echo "$dir_path" | sed "s@\(/[^/]\{$char_limit\}\)[^/]*@\1@g")
  echo "\[${BOLD_BLUE}\]${short_path}\[${GREEN}\]\$(__git_ps1 '(%s)') \[${RESET}\]\\$ "
}
chpwd() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔${RESET}"
  else
    echo -e "${RED}✘${RESET}"
  fi
  if [[ "$PWD" != "$_OLD_PWD" ]]; then
    _OLD_PWD="$PWD"
    ls
    PS1=$(myps1)
  fi
}
PS1=$(myps1)
export PROMPT_COMMAND=chpwd

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck source=/dev/null
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck source=/dev/null
    . /etc/bash_completion
  fi
fi
