#!/bin/zsh
# zshrc
autoload -Uz colors
colors

autoload -U compinit
compinit

zstyle ':completion:*' menu select
setopt completealiases

bindkey -v

setopt HIST_IGNORE_DUPS
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# PS1
# https://qiita.com/tayusa/items/4716869ca7c92842d91f
setopt prompt_subst
myps1_path() {
  local char_limit=3
  local dir_path=$(pwd | sed "s@${HOME}@~@")
  local short_path=$(echo $dir_path | sed "s@\(/[^/]\{$char_limit\}\)[^/]*@\1@g")
  echo $short_path
}
if [ -f "$HOME/.git-prompt.sh" ]; then
  . $HOME/.git-prompt.sh
fi
myps1='%{${fg[white]}${bg[black]}%}$(myps1_path)%{${fg[green]}%}$(__git_ps1 "(%s)") %{${reset_color}%}\$ '
PROMPT=$myps1

# zsh hook
chpwd() {
  ls
  PROMPT=$myps1
}
