#!/bin/bash
#
# Pulse Audio
# arg: "up","down","mute"

set_volume(){
  local idx="@DEFAULT_SINK@"
  case $1 in
    "up")
      pactl set-sink-mute $idx false &&
      pactl set-sink-volume $idx +1% 
      ;;
    "down")
      pactl set-sink-mute $idx false &&
      pactl set-sink-volume $idx -1%
      ;;
    "mute")
      pactl set-sink-mute $idx toggle
      ;;
  esac
}
set_volume $1
