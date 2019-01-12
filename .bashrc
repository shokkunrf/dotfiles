# /bin/bash
#
#

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

myps1_path(){
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

