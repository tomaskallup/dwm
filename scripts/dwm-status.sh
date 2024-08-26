#!/usr/bin/env sh

SEPARATOR=" | ";

get_date() {
  echo "$(date +'%d. %m. %Y %H:%M')"
}

get_battery() {
  local BAT="$(cat /sys/class/power_supply/BAT0/capacity)"
  local STATE="$(cat /sys/class/power_supply/AC/online)"

  local STATUS=""

  if [ $STATE -eq 1 ]; then
    STATUS=" [⚡]"
  fi

  echo "🔋 $BAT%$STATUS$SEPARATOR"
}

get_volume() {
  local Master="$(amixer sget Master)"

  local Side="Left"

  local ON="$(echo $Master | sed -n "s/.* Left: .*\[\(on\)\].*/\1/p")"

  if [ -z $ON ]; then
    Side="Mono"
  fi

  ON="$(echo $Master | sed -n "s/.* $Side: .*\[\(on\)\].*/\1/p")"
  local VOL="$(echo $Master | sed -n "s/.* $Side: .*\[\([0-9]\+\)%\].*/\1/p")"

  if [ "$ON" = "on" ]; then
    VOL="$VOL%"
  else
    VOL="[-]"
  fi

  echo "🔊 $VOL$SEPARATOR"
}

get_cpu_temp() {
  local TEMP="$(sensors | grep -oP 'Package.*?\+\K[0-9.]+')"

  TEMP="$TEMP°C"

  local ICON="🌡"

  echo "$ICON $TEMP$SEPARATOR"
}

get_bluetooth() {
  local devices=$(bluetoothctl devices | sed 's/Device \([^ ]*\) .*/\1/')

  local connected=0

  for device in $devices
  do
    local info=$(bluetoothctl info $device)
    local isconnected=$(echo $info | grep 'Connected: yes')
    if [[ ! -z "$isconnected" ]]; then
      connected=1
    fi
  done

  ICON="[B]"
  STATUS=""

  if [ $connected -gt 0 ]; then
    STATUS=' ✨'
  fi

  echo "$ICON$STATUS$SEPARATOR"
}

get_memory() {
  local info=$(free --si -h)
  local ram=$(echo "$info" | grep Mem:)

  local ram_formatted=$(echo $ram | awk '{printf "%s/%s", $3, $2}')

  STATUS="$ram_formatted"
  ICON="[R] "

  echo "$ICON$STATUS$SEPARATOR"
}

get_cpu_usage() {
  local info=$(grep 'cpu ' /proc/stat)

  echo "$info" | awk '{usage=$2+$4; time=$2+$4+$5} END {print usage" "time}'
}

last_cpu_usage=$(get_cpu_usage)

get_cpu() {
  new_cpu_usage=$(get_cpu_usage)

  # Calculate difference between the two usages
  local cpu_formatted=$(echo "$last_cpu_usage $new_cpu_usage" | awk '{usage=($3-$1); time=($4-$2); value=usage*100/time; printf "%.1f%", value}')
  last_cpu_usage=$new_cpu_usage

  STATUS="$cpu_formatted"
  ICON="[C] "

  echo "$ICON$STATUS$SEPARATOR"
}

while true; do
  sleep 1
  xsetroot -name " $(get_bluetooth)$(get_volume)$(get_battery)$(get_memory)$(get_cpu)$(get_cpu_temp)$(get_date) "
done
