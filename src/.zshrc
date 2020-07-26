#!/bin/zsh
# zshrc
autoload -Uz colors
colors

autoload -U compinit
compinit

zstyle ':completion:*' menu select
setopt completealiases

bindkey -v

#autoload -U promptinit
#promptinit

#PROMPT='%~%{$fg[green]}%}$(__git_ps1 " (%s)")%{$reset_color}%}\$ '

setopt HIST_IGNORE_DUPS
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

