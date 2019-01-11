#!/bin/bash
#
# touchpad toggle enable/disable

touchpad_toggle(){
  local id=`xinput list | grep -Eo "TouchPad\s*id\=[0-9]{1,2}" | grep -Eo "[0-9]{1,2}"`
  local state=`xinput list-props $id | grep "Device Enabled" | grep -Eo ":\s*[0-1]" | grep -Eo "[0-1]"`
  # state=`xinput list-props $id | grep "Device Enabled" | awk '{print $4'}`
  # if [ $state -eq 1 ]; then
  if [ $state = 1 ] ; then
    xinput disable $id
    notify-send "TouchPad disabled" \
      -t 1000
  else
    xinput enable $id
    notify-send "TouchPad enabled" \
      -t 1000
  fi
}
touchpad_toggle

