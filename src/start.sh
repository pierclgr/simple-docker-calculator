#!/bin/bash
set -e

# Start Xvfb (virtual framebuffer)
Xvfb :1 -screen 0 1024x768x24 &
export DISPLAY=:1

# Start window manager
fluxbox &

# Start VNC server (no password for web access)
x11vnc -display :1 -nopw -listen 0.0.0.0 -xkb -forever -shared &

# Start noVNC web server
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

# Wait a moment for services to start
sleep 2

# Start your Python application
python main.py