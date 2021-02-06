#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)

# invoke global X session script
. /etc/X11/Xsession

xset -b #ビープ音を鳴らさない
xmodmap "$HOME/.Xmodmap"
