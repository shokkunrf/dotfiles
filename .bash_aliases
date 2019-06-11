# !/bin/bash
#
# bash alias
alias sudo="sudo "
alias la="ls -la"
alias ks="ls"
alias mkf="touch"

alias upd="apt update && apt list --upgradable"
alias upg="apt upgrade"
alias ins="apt install"

ghq-peco(){
  cd "$( ghq list -p | peco)"
}
alias sd="ghq-peco"

