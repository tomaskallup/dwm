#!/usr/bin/env sh

configure-gtk
systemctl --user import-environment DISPLAY PATH DBUS_SESSION_BUS_ADDRESS
systemctl --user start dwm-session.target
dwm-status.sh &
flameshot &
xset -dpms
