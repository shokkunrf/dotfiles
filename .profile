if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

case "$(uname -a | awk '{print $2}')" in
  "tsukumo")
  	xrandr --output HDMI-1 --primary --left-of VGA-1
    ;;
  *)
    ;;
esac

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
export GOPATH=$HOME/.go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

xmodmap "$HOME/.Xmodmap"
