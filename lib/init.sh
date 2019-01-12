#!/bin/bash
#
# Initialize something

# HOME/bin
for item in $HOME/bin/* ; do
  chmod u+x "$item"
done
