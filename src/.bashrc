#!/bin/bash

shopt -s histappend
HISTCONTROL=ignoredups
HISTFILE=$HOME/.shell_history
HISTSIZE=2000
HISTFILESIZE=100000

shopt -s checkwinsize
shopt -s globstar

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
BOLD_BLUE="\e[1;34m"
RESET="\e[0m"
myps1() {
  local char_limit=3
  local dir_path=$(pwd | sed "s@${HOME}@~@")
  local short_path=$(echo $dir_path | sed "s@\(/[^/]\{$char_limit\}\)[^/]*@\1@g")
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

if [ -f $HOME/.shrc ]; then
    . $HOME/.shrc
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
