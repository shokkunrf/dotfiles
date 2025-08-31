#!/bin/sh

xset -b #ビープ音を鳴らさない

xmodmap "$HOME/.Xmodmap"

touchpad_id=$(xinput list | grep -i Synaptics | head -n1 | grep -oP 'id=\K[0-9]+')
if [ -n "$touchpad_id" ]; then
  xinput set-prop $touchpad_id "libinput Tapping Enabled" 1
  xinput set-prop $touchpad_id "libinput Tapping Drag Enabled" 1
  xinput set-prop $touchpad_id "libinput Natural Scrolling Enabled" 1
fi

exec /usr/bin/x-session-manager
