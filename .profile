if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
export GOPATH=$HOME/.go
export PATH=$PATH:/usr/local/go/bin

xmodmap "$HOME/.Xmodmap"
