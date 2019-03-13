if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

hostname="$(uname -a | awk '{print $2}')"
if [ $hostname = "tsukumo" ] ; then
	xrandr --output HDMI-1 --primary --left-of VGA-1
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
export GOPATH=$HOME/.go
export PATH=$PATH:/usr/local/go/bin

xmodmap "$HOME/.Xmodmap"
