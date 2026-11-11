#!/usr/bin/env bash
# install.sh: install the dotfiles as symlinks into your home directory.
#
# SAFETY SCOPE
#   * Runs as your normal user; refuses to run as root.
#   * Writes only under $HOME. It never touches disks, partitions, LUKS, Btrfs,
#     Snapper, EFI, Limine, Secure Boot or the firewall.
#   * The only privileged step is `sudo pacman -S --needed ...`, and only after
#     you confirm. No AUR packages. No downloaded scripts are executed.
#   * Existing files are moved to a timestamped backup, never deleted.
#
# USAGE
#   ./install.sh [--dry-run] [--yes] [--no-packages] [--no-distro-check]
#     --dry-run          print every action, change nothing
#     --yes              answer "yes" to prompts (backups still happen)
#     --no-packages      skip the package step; only link and validate
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
        die "unsupported distribution '${id:-unknown}'. Use --no-distro-check to override (links only work reliably; packages will not)."
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

# -------------------------------------------------------------------- links
BACKUP_MADE=0
backup_target() {
    local target="$1" rel dest
    rel="${target#"$HOME"/}"
    dest="$BACKUP_DIR/$rel"
    run mkdir -p "$(dirname "$dest")"
    run mv -- "$target" "$dest"
    BACKUP_MADE=1
    log "Backed up $target -> $dest"
}

link_one() {
    local src="$1" target="$2"
    [[ -e $src ]] || die "source missing in repo: $src"

    # Already correct: nothing to do (idempotent).
    if [[ -L $target && "$(readlink -- "$target")" == "$src" ]]; then
        log "ok      $target"; return 0
    fi

    if [[ -e $target || -L $target ]]; then
        warn "$target already exists."
        ask "Move it to the backup directory and link ours?" || { warn "skipped $target"; return 0; }
        backup_target "$target"
    fi

    run mkdir -p "$(dirname "$target")"
    run ln -s -- "$src" "$target"
    log "linked  $target -> $src"
}

link_all() {
    local rel target
    while read -r rel target; do
        [[ -z ${rel:-} || $rel == \#* ]] && continue
        target="${target/#\~/$HOME}"
        case "$target" in "$HOME"/*) ;; *) die "refusing target outside \$HOME: $target" ;; esac
        link_one "$REPO_DIR/$rel" "$target"
    done < "$REPO_DIR/packages/links.txt"
}
link_all

# Executable bits on repo scripts (git preserves them, archives may not).
run chmod +x "$REPO_DIR"/scripts/*.sh "$REPO_DIR/install.sh" "$REPO_DIR/uninstall.sh"

# Lock screen needs a file to include (see hypr/hyprlock.conf); dark theme
# for GTK apps is a per-user setting. Both are harmless to repeat.
run "$REPO_DIR/scripts/wallpaper.sh" init-lock
run "$REPO_DIR/scripts/dark-theme.sh"

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
  Rollback:  $REPO_DIR/uninstall.sh   (removes our links, restores backups)
  Manual:    rm <link>; mv "$BACKUP_DIR/<path>" <original location>
  Neovim:    run once while online:  nvim --headless "+Lazy! sync" +qa
  Zsh:       to make it your login shell:  chsh -s "\$(command -v zsh)"
  Start:     log in on a TTY and run:  start-hyprland   (or select Hyprland in your display manager)
  Recovery:  if Quickshell misbehaves, SUPER+SHIFT+B restarts it; Hyprland keeps running.
EOF
fi
exit "$VALID"
