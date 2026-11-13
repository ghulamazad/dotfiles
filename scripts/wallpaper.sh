#!/usr/bin/env bash
# wallpaper.sh <list|set FILE|set-lock FILE|init-lock|current|random>
#
# The wallpaper itself is drawn by Quickshell (no hyprpaper/swaybg process).
# This script only records the chosen path in a state file that Quickshell
# watches, so changing it never needs a privileged or long-running helper.
set -euo pipefail

# The repo's wallpapers/ sits next to scripts/ (in the repo and, after install.sh,
# under ~/.local/share/dotfiles). readlink -f also keeps this working if someone
# runs it through a symlink.
script_dir="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd -P)"
repo_wall_dir="$(dirname "$script_dir")/wallpapers"
wall_dir="${DOTFILES_WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
state_file="$state_dir/wallpaper"
# hyprlock includes this file (see hypr/hyprlock.conf `source = ...`).
lock_file="$state_dir/hyprlock-bg.conf"

is_image() {
    case "${1,,}" in
        *.png|*.jpg|*.jpeg|*.webp) return 0 ;;
        *) return 1 ;;
    esac
}

list_images() {
    local -a dirs=()
    [[ -d "$wall_dir" ]] && dirs+=("$wall_dir")
    [[ -d "$repo_wall_dir" ]] && dirs+=("$repo_wall_dir")
    (( ${#dirs[@]} )) || return 0
    find "${dirs[@]}" -maxdepth 2 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        | sort -u
}

set_wallpaper() {
    local file="$1"
    [[ -f "$file" ]] || { echo "wallpaper.sh: not a file: $file" >&2; exit 1; }
    is_image "$file" || { echo "wallpaper.sh: unsupported image type: $file" >&2; exit 1; }
    mkdir -p "$state_dir"
    # Write in place so file watchers (Quickshell FileView) see the change.
    printf '%s\n' "$(realpath -- "$file")" > "$state_file"
}

# Lock screen image. hyprlock cannot read our state file, so we write a tiny
# hyprlock snippet instead. `init-lock` makes a plain-colour one if none
# exists, so hyprlock's `source` line never points at a missing file.
write_lock() {
    mkdir -p "$state_dir"
    if [[ -n ${1:-} ]]; then
        printf 'background {\n    monitor =\n    path = %s\n    blur_passes = 2\n}\n' "$1" > "$lock_file"
    else
        printf 'background {\n    monitor =\n    color = rgba(0c1618ff)\n}\n' > "$lock_file"
    fi
}

case "${1:-}" in
    list)    list_images ;;
    current) [[ -f "$state_file" ]] && cat "$state_file" || true ;;
    set)     [[ $# -ge 2 ]] || { echo "usage: wallpaper.sh set FILE" >&2; exit 2; }
             set_wallpaper "$2" ;;
    set-lock)
             [[ $# -ge 2 ]] || { echo "usage: wallpaper.sh set-lock FILE" >&2; exit 2; }
             [[ -f "$2" ]] || { echo "wallpaper.sh: not a file: $2" >&2; exit 1; }
             is_image "$2" || { echo "wallpaper.sh: unsupported image type: $2" >&2; exit 1; }
             write_lock "$(realpath -- "$2")" ;;
    init-lock) [[ -f "$lock_file" ]] || write_lock "" ;;
    random)
        pick="$(list_images | shuf -n 1)"
        [[ -n "$pick" ]] || { echo "wallpaper.sh: no images in $wall_dir" >&2; exit 1; }
        set_wallpaper "$pick" ;;
    *)       echo "usage: wallpaper.sh <list|set FILE|set-lock FILE|init-lock|current|random>" >&2; exit 2 ;;
esac
