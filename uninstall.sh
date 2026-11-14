#!/usr/bin/env bash
# uninstall.sh: remove the files install-config.sh copied.
#
# A copied file is removed only if it is still IDENTICAL to what the installer
# put there. A file you edited since is kept (and reported), so your changes are
# never deleted. Installed packages are NOT removed.
#
# USAGE
#   ./uninstall.sh [--dry-run] [--yes]
# No backups exist, so nothing is restored: a file the installer overwrote is not
# brought back.
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

DRY_RUN=0 ASSUME_YES=0
while (( $# )); do
    case "$1" in
        --dry-run)  DRY_RUN=1 ;;
        --yes|-y)   ASSUME_YES=1 ;;
        -h|--help)  sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "uninstall.sh: unknown option: $1 (try --help)" >&2; exit 2 ;;
    esac
    shift
done

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }
run()  { if (( DRY_RUN )); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }
ask() {
    if (( DRY_RUN )); then printf '    [dry-run] would ask: %s -> assuming yes\n' "$1"; return 0; fi
    (( ASSUME_YES )) && return 0
    local reply; read -r -p "$1 [y/N] " reply </dev/tty || return 1; [[ $reply =~ ^[Yy]$ ]]
}

(( EUID != 0 )) || die "do not run as root."
[[ -n "${HOME:-}" && -d "$HOME" ]] || die "\$HOME is not set to a directory."

(( DRY_RUN )) && log "DRY RUN: nothing will be changed."

MANIFEST="$STATE_DIR/manifest"
[[ -f $MANIFEST ]] || die "no install record ($MANIFEST). Nothing to uninstall."

removed=0 kept=0
while IFS=$'\t' read -r target src; do
    [[ -z ${target:-} ]] && continue
    case "$target" in "$HOME"/*) ;; *) warn "ignoring entry outside \$HOME: $target"; continue ;; esac
    if [[ -f $target && ! -L $target ]]; then
        if [[ -f $src ]] && cmp -s -- "$src" "$target"; then
            run rm -f -- "$target"
            removed=$((removed + 1))
        else
            warn "kept $target (edited since install, or repo copy is gone)"
            kept=$((kept + 1))
            continue
        fi
    elif [[ -e $target || -L $target ]]; then
        warn "kept $target (not a regular file)"; continue
    fi
done < "$MANIFEST"
log "Removed $removed file(s), kept $kept edited file(s)."

# Tidy: remove directories that became empty (only empty ones; rmdir cannot delete content).
if (( ! DRY_RUN )); then
    cut -f1 "$MANIFEST" | while IFS= read -r f; do dirname "$f"; done | sort -u -r | while IFS= read -r d; do
        case "$d" in "$HOME"/*) while [[ $d != "$HOME" ]] && rmdir "$d" 2>/dev/null; do d="$(dirname "$d")"; done ;; esac
    done
    rm -f "$MANIFEST"
fi

log "Done. Packages were not removed; use pacman -Rns manually if you want them gone."
