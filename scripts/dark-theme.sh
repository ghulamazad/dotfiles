#!/usr/bin/env bash
# dark-theme.sh: ask GTK 3/4 apps (Nautilus and friends) for the dark look.
set -euo pipefail

if ! command -v gsettings >/dev/null 2>&1; then
    echo "dark-theme.sh: gsettings not found (install glib2 / dconf); skipping." >&2
    exit 0
fi

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' \
    || echo "dark-theme.sh: could not set color-scheme (no D-Bus session?)." >&2
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' \
    || echo "dark-theme.sh: could not set gtk-theme." >&2

# Tela is AUR-only, so it may not be installed. Use the first variant that exists.
icons=""
for name in Tela-green-dark Tela-dark Tela; do
    for root in "$HOME/.local/share/icons" "$HOME/.icons" /usr/share/icons; do
        if [[ -z "$icons" && -f "$root/$name/index.theme" ]]; then icons="$name"; fi
    done
done
if [[ -n "$icons" ]]; then
    gsettings set org.gnome.desktop.interface icon-theme "$icons" \
        || echo "dark-theme.sh: could not set icon-theme." >&2
else
    echo "dark-theme.sh: Tela icon theme not found; keeping the current icons." >&2
fi