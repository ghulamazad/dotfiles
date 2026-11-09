#!/usr/bin/env bash
# wallpaper.sh <list|set FILE|current|random>
#
# The wallpaper itself is drawn by Quickshell (no hyprpaper/swaybg process).
# This script only records the chosen path in a state file that Quickshell
# watches, so changing it never needs a privileged or long-running helper.
set -euo pipefail

wall_dir="${DOTFILES_WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
state_file="$state_dir/wallpaper"

is_image() {
    case "${1,,}" in
        *.png|*.jpg|*.jpeg|*.webp) return 0 ;;
        *) return 1 ;;
    esac
}

list_images() {
    [[ -d "$wall_dir" ]] || return 0
    find "$wall_dir" -maxdepth 2 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        | sort
}

set_wallpaper() {
    local file="$1"
    [[ -f "$file" ]] || { echo "wallpaper.sh: not a file: $file" >&2; exit 1; }
    is_image "$file" || { echo "wallpaper.sh: unsupported image type: $file" >&2; exit 1; }
    mkdir -p "$state_dir"
    # Write in place so file watchers (Quickshell FileView) see the change.
    printf '%s\n' "$(realpath -- "$file")" > "$state_file"
}

case "${1:-}" in
    list)    list_images ;;
    current) [[ -f "$state_file" ]] && cat "$state_file" || true ;;
    set)     [[ $# -ge 2 ]] || { echo "usage: wallpaper.sh set FILE" >&2; exit 2; }
             set_wallpaper "$2" ;;
    random)
        pick="$(list_images | shuf -n 1)"
        [[ -n "$pick" ]] || { echo "wallpaper.sh: no images in $wall_dir" >&2; exit 1; }
        set_wallpaper "$pick" ;;
    *)       echo "usage: wallpaper.sh <list|set FILE|current|random>" >&2; exit 2 ;;
esac
