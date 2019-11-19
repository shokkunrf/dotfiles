#!/bin/bash
#
# Initialize something

# HOME/bin
for item in $HOME/bin/* ; do
  chmod u+x "$item"
done

xmodmap -pke > default.xmodmap

git config --global alias.st status
git config --global alias.br branch
git config --global alias.ch checkout
git config --global alias.ad add
git config --global alias.cm commit
git config --global alias.re reset
