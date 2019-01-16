#!/bin/bash
#
#
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi
export GOPATH=$HOME/.go

xmodmap "${HOME}/.Xmodmap"
