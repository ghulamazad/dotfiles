#!/usr/bin/env bash
# dark-theme.sh: ask GTK 3/4 apps (Nautilus and friends) for the dark look.
#
# `color-scheme` is the freedesktop dark-mode hint. Apps that follow the XDG
# settings portal (xdg-desktop-portal-gtk is in packages.txt) read it, and so do
# some Qt 6 and browser apps. Apps with their own theme setting (Telegram, OBS,
# browsers) may still need a manual switch. Qt apps that ignore the hint need a
# Qt theme tool such as qt6ct; that is NOT configured here.
set -euo pipefail

if ! command -v gsettings >/dev/null 2>&1; then
    echo "dark-theme.sh: gsettings not found (install glib2 / dconf); skipping." >&2
    exit 0
fi

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' \
    || echo "dark-theme.sh: could not set color-scheme (no D-Bus session?)." >&2
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' \
    || echo "dark-theme.sh: could not set gtk-theme." >&2
