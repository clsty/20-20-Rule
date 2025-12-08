#!/bin/bash
cd "$(dirname $0)"
base="$(pwd)"
soundfile="$base/ding.mp3"
period_minutes=20
break_seconds=20
notify-send --urgency=normal --expire-time=3000 --app-name=Reminder "Reminder Starts."
while :
do
  sleep $((period_minutes*60))
  notify-send --urgency=normal --expire-time=$((break_seconds*1000)) --app-name=Reminder "Take a break" "Look an object 20m far for ${break_seconds}s."
  mpv "$soundfile"
  sleep ${break_seconds}
  mpv "$soundfile"
done
