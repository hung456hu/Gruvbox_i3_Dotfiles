#!/bin/bash
# Lấy PID của cửa sổ đang focus
PID=$(xdotool getwindowfocus getwindowpid)

# Kill toàn bộ tiến trình liên quan
kill -9 $PID
