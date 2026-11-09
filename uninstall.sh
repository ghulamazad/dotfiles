#!/usr/bin/env bash
# uninstall.sh: remove the symlinks created by install.sh and restore backups.
#
# It only removes a link if it points INTO this repository, so a file or link
# you created yourself is never touched. Installed packages are NOT removed.
#
# USAGE
#   ./uninstall.sh [--dry-run] [--yes] [--backup DIR]
#     --backup DIR   restore from DIR (default: the backup recorded by install.sh)
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

DRY_RUN=0 ASSUME_YES=0 BACKUP_DIR=""
while (( $# )); do
    case "$1" in
        --dry-run)  DRY_RUN=1 ;;
        --yes|-y)   ASSUME_YES=1 ;;
        --backup)   shift; BACKUP_DIR="${1:-}"; [[ -n $BACKUP_DIR ]] || { echo "--backup needs a directory" >&2; exit 2; } ;;
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

if [[ -z $BACKUP_DIR && -f "$STATE_DIR/last-backup" ]]; then
    BACKUP_DIR="$(<"$STATE_DIR/last-backup")"
fi
if [[ -n $BACKUP_DIR && ! -d $BACKUP_DIR ]]; then
    warn "Recorded backup directory is missing: $BACKUP_DIR"; BACKUP_DIR=""
fi
if [[ -n $BACKUP_DIR ]]; then
    log "Using backup: $BACKUP_DIR"
else
    warn "No backup found: links will be removed, nothing restored."
fi

(( DRY_RUN )) && log "DRY RUN: nothing will be changed."

while read -r rel target; do
    [[ -z ${rel:-} || $rel == \#* ]] && continue
    target="${target/#\~/$HOME}"
    case "$target" in "$HOME"/*) ;; *) die "refusing target outside \$HOME: $target" ;; esac
    src="$REPO_DIR/$rel"

    if [[ -L $target && "$(readlink -- "$target")" == "$src" ]]; then
        ask "Remove link $target?" || { warn "kept $target"; continue; }
        run rm -- "$target"
        log "removed $target"
    elif [[ -e $target || -L $target ]]; then
        warn "$target is not our link; leaving it alone."
        continue
    fi

    if [[ -n $BACKUP_DIR ]]; then
        backup_path="$BACKUP_DIR/${target#"$HOME"/}"
        if [[ -e $backup_path || -L $backup_path ]] && [[ ! -e $target && ! -L $target ]]; then
            run mkdir -p "$(dirname "$target")"
            run mv -- "$backup_path" "$target"
            log "restored $target"
        fi
    fi
done < "$REPO_DIR/packages/links.txt"

log "Done. Packages were not removed; use pacman -Rns manually if you want them gone."
