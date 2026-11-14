#!/usr/bin/env bash
# install.sh: install (COPY) the dotfiles into your home directory.
# The repo and your live config are separate: edit either, re-run this script
# to deploy repo changes. Nothing in $HOME points back into the repo.
#
# SAFETY SCOPE
#   * Runs as your normal user; refuses to run as root.
#   * Writes only under $HOME. It never touches disks, partitions, LUKS, Btrfs,
#     Snapper, EFI, Limine, Secure Boot or the firewall.
#   * The only privileged step is `sudo pacman -S --needed ...`, and only after
#     you confirm. No AUR packages. No downloaded scripts are executed.
#   * A file that differs from the repo's version is copied to a timestamped
#     backup before it is overwritten. Files that are not in the repo (for
#     example hypr/local.lua) are never touched.
#
# USAGE
#   ./install.sh [--dry-run] [--yes] [--no-packages] [--no-distro-check]
#     --dry-run          print every action, change nothing
#     --yes              answer "yes" to prompts (backups still happen)
#     --no-packages      skip the package step; only copy and validate
#     --no-distro-check  allow other distributions (also used for testing)
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles-backup/$TIMESTAMP"

DRY_RUN=0 ASSUME_YES=0 DO_PACKAGES=1 CHECK_DISTRO=1
for arg in "$@"; do
    case "$arg" in
        --dry-run)         DRY_RUN=1 ;;
        --yes|-y)          ASSUME_YES=1 ;;
        --no-packages)     DO_PACKAGES=0 ;;
        --no-distro-check) CHECK_DISTRO=0 ;;
        -h|--help)         sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "install.sh: unknown option: $arg (try --help)" >&2; exit 2 ;;
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
(( EUID != 0 )) || die "do not run as root. Run as your normal user; sudo is requested only for pacman."
[[ -n "${HOME:-}" && -d "$HOME" ]] || die "\$HOME is not set to a directory."
[[ -f "$REPO_DIR/packages/links.txt" ]] || die "packages/links.txt not found next to install.sh."

detect_distro() {
    local id="" like=""
    if [[ -r /etc/os-release ]]; then
        id="$(. /etc/os-release; echo "${ID:-}")"
        like="$(. /etc/os-release; echo "${ID_LIKE:-}")"
    fi
    if [[ $id == arch ]]; then
        log "Detected Arch Linux."
    elif [[ $like == *arch* ]]; then
        warn "This is '$id', an Arch derivative, not Arch Linux. Package names should match, but its repositories may differ."
        ask "Continue anyway?" || die "aborted."
    else
        die "unsupported distribution '${id:-unknown}'. Use --no-distro-check to override (file copying works; packages will not)."
    fi
}
if (( CHECK_DISTRO )); then detect_distro; else warn "Distro check skipped."; fi

(( DRY_RUN )) && log "DRY RUN: nothing will be changed."

# ----------------------------------------------------------------- packages
install_packages() {
    command -v pacman >/dev/null 2>&1 || { warn "pacman not found; skipping packages."; return 0; }

    local -a wanted=() missing=() unknown=()
    local line pkg
    while IFS= read -r line; do
        pkg="${line%%#*}"; pkg="${pkg//[[:space:]]/}"
        [[ -n $pkg ]] && wanted+=("$pkg")
    done < "$REPO_DIR/packages/packages.txt"

    for pkg in "${wanted[@]}"; do
        pacman -Qq "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    if (( ${#missing[@]} == 0 )); then log "All ${#wanted[@]} packages already installed."; return 0; fi

    # Verify names exist in the configured repos before asking the user.
    local -a installable=()
    for pkg in "${missing[@]}"; do
        if pacman -Si "$pkg" >/dev/null 2>&1; then installable+=("$pkg"); else unknown+=("$pkg"); fi
    done
    if (( ${#unknown[@]} )); then
        warn "Not found in your configured repositories (sync with 'sudo pacman -Sy' or fix packages.txt):"
        printf '      %s\n' "${unknown[@]}" >&2
    fi
    (( ${#installable[@]} )) || return 0

    log "Missing packages (${#installable[@]}): ${installable[*]}"
    if ask "Install these with 'sudo pacman -S --needed'?"; then
        # No --noconfirm: pacman shows its own prompt so you can review.
        run sudo pacman -S --needed "${installable[@]}"
    else
        warn "Skipped package installation."
    fi
}
if (( DO_PACKAGES )); then install_packages; else log "Skipping packages (--no-packages)."; fi

# --------------------------------------------------------------------- copy
BACKUP_MADE=0
MANIFEST="$STATE_DIR/manifest"       # "target<TAB>source" per installed file
NEW_MANIFEST="$(mktemp)"
trap 'rm -f "$NEW_MANIFEST"' EXIT
N_NEW=0 N_CHANGED=0 N_SAME=0

backup_file() {
    local target="$1" rel dest
    rel="${target#"$HOME"/}"
    dest="$BACKUP_DIR/$rel"
    run mkdir -p "$(dirname "$dest")"
    run cp -a -- "$target" "$dest"
    BACKUP_MADE=1
}

# Copy one file. Returns quietly if it is already identical.
copy_file() {
    local src="$1" target="$2"
    printf '%s\t%s\n' "$target" "$src" >> "$NEW_MANIFEST"
    if [[ -f $target && ! -L $target ]] && cmp -s -- "$src" "$target"; then
        N_SAME=$((N_SAME + 1)); return 0
    fi
    if [[ -e $target || -L $target ]]; then
        backup_file "$target"
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
            ask "Move it to the backup directory and copy ours?" || { warn "skipped $target"; return 0; }
            local rel_t="${target#"$HOME"/}"
            run mkdir -p "$(dirname "$BACKUP_DIR/$rel_t")"
            run mv -- "$target" "$BACKUP_DIR/$rel_t"
            BACKUP_MADE=1
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
            ask "Back them up to $BACKUP_DIR and overwrite?" || { warn "skipped $target"; return 0; }
        fi
        while IFS= read -r -d '' f; do
            rel="${f#"$src"/}"
            copy_file "$f" "$target/$rel"
        done < <(find "$src" -type f -print0)
    else
        if [[ -e $target ]] && ! cmp -s -- "$src" "$target"; then
            warn "$target differs from the repo version."
            ask "Back it up to $BACKUP_DIR and overwrite?" || { warn "skipped $target"; return 0; }
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
    log "Files: $N_NEW new, $N_CHANGED updated (old version backed up), $N_SAME already identical."
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
run chmod +x "$REPO_DIR"/scripts/*.sh "$REPO_DIR"/scripts-local/* "$REPO_DIR/install.sh" "$REPO_DIR/uninstall.sh"
(( DRY_RUN )) || chmod +x "$HOME/.local/share/dotfiles/scripts/"*.sh "$HOME/.local/scripts/"* 2>/dev/null || true

# Lock screen needs a file to include (see hypr/hyprlock.conf); dark theme
# for GTK apps is a per-user setting. Both are harmless to repeat.
run "$HOME/.local/share/dotfiles/scripts/wallpaper.sh" init-lock
run "$HOME/.local/share/dotfiles/scripts/dark-theme.sh"

# Remember where the backup is so uninstall.sh can restore it.
if (( BACKUP_MADE && ! DRY_RUN )); then
    mkdir -p "$STATE_DIR"
    printf '%s\n' "$BACKUP_DIR" > "$STATE_DIR/last-backup"
fi

# --------------------------------------------------------------- validation
validate() {
    local bad=0 f
    log "Validating configuration files..."

    for f in "$REPO_DIR"/install.sh "$REPO_DIR"/uninstall.sh "$REPO_DIR"/scripts/*.sh; do
        bash -n "$f" || { warn "shell syntax error: $f"; bad=1; }
    done
    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck -x "$REPO_DIR"/scripts/*.sh "$REPO_DIR"/install.sh "$REPO_DIR"/uninstall.sh || bad=1
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
    if (( ${#absent[@]} )); then warn "Commands not found yet: ${absent[*]}"; else log "All required commands are present."; fi

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
    if (( BACKUP_MADE )); then
        echo "  Backups:   $BACKUP_DIR"
    fi
    cat <<EOF
  Update:    edit the repo, then re-run ./install.sh --yes (only changed files are copied)
  Rollback:  $REPO_DIR/uninstall.sh   (removes unmodified copies, restores backups)
  Manual:    your old files are in "$BACKUP_DIR"
  Neovim:    run once while online:  nvim --headless "+Lazy! sync" +qa
  Zsh:       to make it your login shell:  chsh -s "\$(command -v zsh)"
  Start:     log in on a TTY and run:  start-hyprland   (or select Hyprland in your display manager)
  Recovery:  if Quickshell misbehaves, SUPER+SHIFT+B restarts it; Hyprland keeps running.
EOF
fi
exit "$VALID"
