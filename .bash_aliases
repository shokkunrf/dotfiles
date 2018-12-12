# !/bin/bash
#
# bash alias
echo 'Hello,'

alias sudo="sudo "
alias la="ls -la"
alias ks="ls"
alias mkf="touch"

cdls()
{
  \cd "$@" && pwd && ls
}
#alias cd="cdls"

alias upd="apt update && apt list --upgradable"
alias upg="apt upgrade"
alias ins="apt install"

myps1_path(){
  # array split'/' pwd
  local readonly DIR_PATH=($(echo $PWD | tr '/' ' '))
  local readonly CURRENT_DIR="${DIR_PATH[${#DIR_PATH[@]}-1]}"
  unset DIR_PATH[${#DIR_PATH[@]}-1]

  local result=""
  for dir in ${DIR_PATH[@]}; do
    result="$result/${dir:0:3}"
  done
  echo "${result}/${CURRENT_DIR}"
}

myps1='\[\e[1;32m\]$(myps1_path)\[\e[0;32m\]$ \[\e[0m\]'
auto_cdls(){
  if [ "$OLDPWD" != "$PWD" ]; then
    ls
    OLDPWD="$PWD"
    PS1="${myps1}"
  fi
}
PROMPT_COMMAND="auto_cdls"
export PS1="${myps1}"

echo "World"

