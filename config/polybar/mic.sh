#!/bin/sh

if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes"; then
  # muted → màu xám
  echo "%{F#d5c4a1}muted%{F-}"
else
  # active → % bình thường
  pactl get-source-volume @DEFAULT_SOURCE@ |
    awk 'NR==1 {print $5}'
fi
