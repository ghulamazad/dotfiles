#!/usr/bin/env bash
# install-config.sh: copy the dotfiles into your home directory. NO packages.
# (Run install-packages.sh first on a fresh system: it installs the programs.)
# The repo and your live config are separate: edit either, re-run this script
# to deploy repo changes. Nothing in $HOME points back into the repo.
#
# SAFETY SCOPE
#   * Runs as your normal user; refuses to run as root. Never uses sudo.
#   * Writes only under $HOME. It never touches disks, partitions, LUKS, Btrfs,
#     Snapper, EFI, Limine, Secure Boot or the firewall.
#   * NO BACKUPS are made. A file that differs from the repo's version is
#     overwritten (you are asked first, unless --yes). Files that are not in the
#     repo (for example hypr/local.lua) are never touched.
#
# USAGE
#   ./install-config.sh [--dry-run] [--yes]
#     --dry-run   print every action, change nothing
#     --yes       answer "yes" to prompts (existing files are overwritten without asking)
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

DRY_RUN=0 ASSUME_YES=0
for arg in "$@"; do
    case "$arg" in
        --dry-run)         DRY_RUN=1 ;;
        --yes|-y)          ASSUME_YES=1 ;;
        -h|--help)         sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "install-config.sh: unknown option: $arg (try --help)" >&2; exit 2 ;;
    esac
done

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if (( DRY_RUN )); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi
}

ask() {
    if (( DRY_RUN )); then printf '    [dry-run] would ask: %s -> assuming yes\n' "$1"; return 0; fi
    (( ASSUME_YES )) && return 0
    local reply
    read -r -p "$1 [y/N] " reply </dev/tty || return 1
    [[ $reply =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------- preflight
(( EUID != 0 )) || die "do not run as root. Run as your normal user."
[[ -n "${HOME:-}" && -d "$HOME" ]] || die "\$HOME is not set to a directory."
[[ -f "$REPO_DIR/packages/links.txt" ]] || die "packages/links.txt not found next to install-config.sh."

(( DRY_RUN )) && log "DRY RUN: nothing will be changed."

# --------------------------------------------------------------------- copy
MANIFEST="$STATE_DIR/manifest"       # "target<TAB>source" per installed file
NEW_MANIFEST="$(mktemp)"
trap 'rm -f "$NEW_MANIFEST"' EXIT
N_NEW=0 N_CHANGED=0 N_SAME=0

# Copy one file. Returns quietly if it is already identical.
copy_file() {
    local src="$1" target="$2"
    printf '%s\t%s\n' "$target" "$src" >> "$NEW_MANIFEST"
    if [[ -f $target && ! -L $target ]] && cmp -s -- "$src" "$target"; then
        N_SAME=$((N_SAME + 1)); return 0
    fi
    if [[ -e $target || -L $target ]]; then
        run rm -f -- "$target"
        N_CHANGED=$((N_CHANGED + 1))
    else
        N_NEW=$((N_NEW + 1))
    fi
    run mkdir -p "$(dirname "$target")"
    run cp -p -- "$src" "$target"
}

# Copy a file or a whole directory tree. Extra files already in the target
# directory (local.lua, caches, plugin lockfile edits) are left alone.
copy_entry() {
    local src="$1" target="$2" f rel
    [[ -e $src ]] || die "source missing in repo: $src"

    # An older symlink-based install: replace our own link with real files.
    if [[ -L $target ]]; then
        if [[ "$(readlink -f -- "$target")" == "$src" || "$(readlink -f -- "$target")" == "$REPO_DIR"/* ]]; then
            log "replacing old symlink $target with a copy"
            run rm -- "$target"
        else
            warn "$target is a symlink to somewhere else."
            ask "Remove that symlink (not what it points to) and copy ours?" || { warn "skipped $target"; return 0; }
            run rm -- "$target"
        fi
    fi

    if [[ -d $src ]]; then
        [[ -e $target && ! -d $target ]] && die "$target exists and is not a directory."
        # Ask once per entry if anything would be overwritten.
        local differing=0
        while IFS= read -r -d '' f; do
            rel="${f#"$src"/}"
            if [[ -e $target/$rel ]] && ! cmp -s -- "$f" "$target/$rel"; then differing=$((differing + 1)); fi
        done < <(find "$src" -type f -print0)
        if (( differing )); then
            warn "$differing file(s) in $target differ from the repo version."
            ask "Overwrite them (no backup is made)?" || { warn "skipped $target"; return 0; }
        fi
        while IFS= read -r -d '' f; do
            rel="${f#"$src"/}"
            copy_file "$f" "$target/$rel"
        done < <(find "$src" -type f -print0)
    else
        if [[ -e $target ]] && ! cmp -s -- "$src" "$target"; then
            warn "$target differs from the repo version."
            ask "Overwrite it (no backup is made)?" || { warn "skipped $target"; return 0; }
        fi
        copy_file "$src" "$target"
    fi
    log "ok      $target"
}

copy_all() {
    local rel target
    while read -r rel target; do
        [[ -z ${rel:-} || $rel == \#* ]] && continue
        target="${target/#\~/$HOME}"
        case "$target" in "$HOME"/*) ;; *) die "refusing target outside \$HOME: $target" ;; esac
        copy_entry "$REPO_DIR/$rel" "$target"
    done < "$REPO_DIR/packages/links.txt"
    log "Files: $N_NEW new, $N_CHANGED overwritten, $N_SAME already identical."
}
copy_all

# Remember what we installed so uninstall.sh removes only unmodified copies.
if (( ! DRY_RUN )); then
    mkdir -p "$STATE_DIR"
    # New entries first; awk keeps the first line per target. (cat on a missing
    # old manifest must not abort the script under `set -e`.)
    { cat "$NEW_MANIFEST"; if [[ -f $MANIFEST ]]; then cat "$MANIFEST"; fi; } \
        | awk -F'\t' '!seen[$1]++' > "$MANIFEST.tmp"
    mv "$MANIFEST.tmp" "$MANIFEST"
fi

# Executable bits on repo scripts (git preserves them, archives may not).
run chmod +x "$REPO_DIR"/scripts/* "$REPO_DIR/install-packages.sh" "$REPO_DIR/install-config.sh" "$REPO_DIR/uninstall.sh"
(( DRY_RUN )) || chmod +x "$HOME/.local/scripts/"* 2>/dev/null || true

# Lock screen needs a file to include (see hypr/hyprlock.conf); dark theme
# for GTK apps is a per-user setting. Both are harmless to repeat.
run "$HOME/.local/scripts/wallpaper.sh" init-lock
run "$HOME/.local/scripts/dark-theme.sh"

# --------------------------------------------------------------- validation
validate() {
    local bad=0 f
    log "Validating configuration files..."

    for f in "$REPO_DIR"/install-packages.sh "$REPO_DIR"/install-config.sh "$REPO_DIR"/uninstall.sh "$REPO_DIR"/scripts/*.sh; do
        bash -n "$f" || { warn "shell syntax error: $f"; bad=1; }
    done
    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck -x "$REPO_DIR"/scripts/*.sh "$REPO_DIR"/install-packages.sh "$REPO_DIR"/install-config.sh "$REPO_DIR"/uninstall.sh || bad=1
    else
        log "shellcheck not installed; skipped lint."
    fi

    # Lua syntax (Hyprland + Neovim configs). Needs a standalone Lua or luac.
    local luac=""
    for c in luac luac5.4 luac5.5 luajit; do command -v "$c" >/dev/null 2>&1 && { luac="$c"; break; }; done
    if [[ -n $luac ]]; then
        while IFS= read -r -d '' f; do
            if [[ $luac == luajit ]]; then luajit -bl "$f" >/dev/null 2>&1 || { warn "Lua syntax error: $f"; bad=1; }
            else "$luac" -p "$f" || { warn "Lua syntax error: $f"; bad=1; }; fi
        done < <(find "$REPO_DIR/hypr" "$REPO_DIR/nvim" -name '*.lua' -print0)
    else
        log "No luac/luajit found; skipped Lua syntax check (pacman -S lua)."
    fi

    # QML lint, if Qt's qmllint is available.
    local qmllint=""
    for c in qmllint-qt6 qmllint6 qmllint; do command -v "$c" >/dev/null 2>&1 && { qmllint="$c"; break; }; done
    if [[ -n $qmllint && -d $REPO_DIR/quickshell ]]; then
        log "qmllint found ($qmllint). Run it manually: it needs Quickshell's import paths to be useful."
    fi

    # Every command the keybindings and scripts rely on.
    local -a need=(Hyprland qs ghostty nautilus btop jq nvim zsh grim slurp wl-copy wl-paste cliphist hypridle hyprlock brightnessctl wpctl playerctl nmcli bluetoothctl)
    local -a absent=()
    for c in "${need[@]}"; do command -v "$c" >/dev/null 2>&1 || absent+=("$c"); done
    if (( ${#absent[@]} )); then warn "Commands not found yet: ${absent[*]} (run ./install-packages.sh)"; else log "All required commands are present."; fi

    return "$bad"
}
VALID=0
validate || VALID=1

# ------------------------------------------------------------------ summary
echo
if (( DRY_RUN )); then
    log "Dry run finished. Re-run without --dry-run to apply."
else
    log "Done."
    cat <<EOF
  Update:    edit the repo, then re-run ./install-config.sh --yes (only changed files are copied)
  Rollback:  $REPO_DIR/uninstall.sh   (removes the copies it made, if you have not edited them)
  Neovim:    run once while online:  nvim --headless "+Lazy! sync" +qa
  Zsh:       to make it your login shell:  chsh -s "\$(command -v zsh)"
  Start:     log in on a TTY and run:  start-hyprland   (or select Hyprland in your display manager)
  Recovery:  if Quickshell misbehaves, SUPER+SHIFT+B restarts it; Hyprland keeps running.
EOF
fi
exit "$VALID"
