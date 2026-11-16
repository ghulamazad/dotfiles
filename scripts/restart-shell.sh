#!/usr/bin/env bash
# restart-shell.sh: restart Quickshell without touching Hyprland.
# Bound to SUPER+SHIFT+B. Safe to run when Quickshell has crashed or is
# not running at all.
set -u

# Ask Quickshell to exit cleanly; fall back to terminating by exact name.
if command -v qs >/dev/null 2>&1; then
    qs kill >/dev/null 2>&1 || pkill -x quickshell >/dev/null 2>&1 || true
else
    pkill -x quickshell >/dev/null 2>&1 || true
fi

sleep 0.4

if ! command -v qs >/dev/null 2>&1; then
    command -v notify-send >/dev/null 2>&1 && notify-send -u critical "Shell restart failed" "quickshell is not installed"
    exit 1
fi

# setsid -f detaches it from this script so it survives after we exit.
setsid -f qs >/dev/null 2>&1
