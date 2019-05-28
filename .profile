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
PATH="$PATH:$HOME/.anyenv/bin"
export PATH

eval "$(anyenv init -)"

xmodmap "$HOME/.Xmodmap"

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi