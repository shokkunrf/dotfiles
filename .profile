xset -b #ビープ音を鳴らさない
case "$(uname -a | awk '{print $2}')" in
  "tsukumo")
  	xrandr --output HDMI-1 --primary --left-of VGA-1
    ;;
  "asparagus" )
    xrandr --output DP-3 --primary --left-of HDMI-0
    xrandr --output HDMI-0 --mode 1920x1080
    ;;
  *)
    ;;
esac

PATH="$PATH:$HOME/bin"
PATH="$PATH:$HOME/_bin"
export GOPATH="$HOME/.go"
PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
PATH="$PATH:$HOME/.anyenv/bin"
export PATH

eval "$(anyenv init -)"

xmodmap "$HOME/.Xmodmap"

if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
