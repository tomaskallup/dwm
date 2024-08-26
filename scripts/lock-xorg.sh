#!/usr/bin/env sh

i3lock-fancy-rapid 5 3
# Make sure we reset brightness & dpms
xrandr --output $(xrandr | grep primary | awk '{print $1}') --brightness 1
