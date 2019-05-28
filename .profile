case "$(uname -a | awk '{print $2}')" in
  "tsukumo")
  	xrandr --output HDMI-1 --primary --left-of VGA-1
    ;;
  *)
    ;;
esac

PATH="$PATH:$HOME/bin"
PATH="$PATH:$HOME/_bin"
export GOPATH="$HOME/.go"
PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
export PATH

xmodmap "$HOME/.Xmodmap"
