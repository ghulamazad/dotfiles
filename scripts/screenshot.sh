#!/usr/bin/env bash
# screenshot.sh <region|screen>
# Saves a PNG to ~/Pictures/Screenshots and copies it to the clipboard.
# Needs: grim, slurp (region mode), wl-clipboard. notify-send is optional and
# shows through the Quickshell notification server.
set -euo pipefail

mode="${1:-region}"
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a screenshot "$@" || true; }

for dep in grim wl-copy; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        notify "Screenshot failed" "Missing dependency: $dep"
        echo "screenshot.sh: missing dependency: $dep" >&2
        exit 1
    fi
done

mkdir -p "$dir"

case "$mode" in
    region)
        command -v slurp >/dev/null 2>&1 || { notify "Screenshot failed" "Missing dependency: slurp"; exit 1; }
        # slurp exits non-zero when the user presses Escape: treat as cancel.
        geometry="$(slurp)" || exit 0
        grim -g "$geometry" "$file"
        ;;
    screen)
        grim "$file"
        ;;
    *)
        echo "usage: screenshot.sh <region|screen>" >&2
        exit 2
        ;;
esac

wl-copy --type image/png < "$file"
notify "Screenshot saved" "$file"
