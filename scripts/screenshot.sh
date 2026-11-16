#!/usr/bin/env bash

set -euo pipefail

mode="${1:-select}"
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a screenshot "$@" || true; }
need() {
    command -v "$1" >/dev/null 2>&1 && return 0
    notify "Screenshot failed" "Missing dependency: $1"
    echo "screenshot.sh: missing dependency: $1" >&2
    exit 1
}

# Rectangles ("x,y WxH") of the windows that are visible right now, i.e. on a
# workspace that is active on some monitor. slurp lets you click inside one to
# pick that window, or drag anywhere to pick an area.
window_rects() {
    local active
    active="$(hyprctl monitors -j | jq -c '[.[].activeWorkspace.id]')"
    hyprctl clients -j | jq -r --argjson ws "$active" '
        .[]
        | select(.mapped and (.hidden | not) and ((.workspace.id) as $w | $ws | index($w)))
        | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

need grim
need wl-copy
mkdir -p "$dir"

case "$mode" in
    select)
        need slurp
        need jq
        need hyprctl
        # slurp exits non-zero when the user presses Escape: treat as cancel.
        geometry="$(window_rects | slurp)" || exit 0
        [[ -n $geometry ]] || exit 0
        grim -g "$geometry" "$file"
        ;;
    screen)
        grim "$file"
        ;;
    *)
        echo "usage: screenshot.sh <select|screen>" >&2
        exit 2
        ;;
esac

wl-copy --type image/png < "$file"
notify "Screenshot saved" "$file"
