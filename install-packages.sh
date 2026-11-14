#!/usr/bin/env bash
# install-packages.sh: install the programs this setup needs. NO config files.
# (Run install-config.sh afterwards to copy the configuration.)
#
# SAFETY SCOPE
#   * Runs as your normal user; refuses to run as root.
#   * The only privileged step is `sudo pacman -S --needed ...`, and only after
#     you confirm. pacman shows its own prompt too (no --noconfirm).
#   * Official repositories only. No AUR packages. No downloaded scripts are run.
#   * Never touches disks, partitions, LUKS, Btrfs, Snapper, EFI or the bootloader.
#   * Does not enable any service; it prints the commands for you to run.
#
# USAGE
#   ./install-packages.sh [--dry-run] [--yes] [--no-distro-check]
#     --dry-run          list what would be installed, change nothing
#     --yes              answer "yes" to this script's own prompt (pacman still asks)
#     --no-distro-check  allow other distributions (testing only)
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0 ASSUME_YES=0 CHECK_DISTRO=1
for arg in "$@"; do
    case "$arg" in
        --dry-run)         DRY_RUN=1 ;;
        --yes|-y)          ASSUME_YES=1 ;;
        --no-distro-check) CHECK_DISTRO=0 ;;
        -h|--help)         sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "install-packages.sh: unknown option: $arg (try --help)" >&2; exit 2 ;;
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
[[ -f "$REPO_DIR/packages/packages.txt" ]] || die "packages/packages.txt not found next to install-packages.sh."

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
        die "unsupported distribution '${id:-unknown}'. This script is for Arch Linux (pacman)."
    fi
}
if (( CHECK_DISTRO )); then detect_distro; else warn "Distro check skipped."; fi
command -v pacman >/dev/null 2>&1 || die "pacman not found."

(( DRY_RUN )) && log "DRY RUN: nothing will be changed."

# ----------------------------------------------------------------- packages
wanted=() missing=() unknown=() installable=()
while IFS= read -r line; do
    pkg="${line%%#*}"; pkg="${pkg//[[:space:]]/}"
    [[ -n $pkg ]] && wanted+=("$pkg")
done < "$REPO_DIR/packages/packages.txt"

for pkg in "${wanted[@]}"; do
    pacman -Qq "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if (( ${#missing[@]} == 0 )); then
    log "All ${#wanted[@]} packages already installed."
else
    # Verify names exist in the configured repos before asking.
    for pkg in "${missing[@]}"; do
        if pacman -Si "$pkg" >/dev/null 2>&1; then installable+=("$pkg"); else unknown+=("$pkg"); fi
    done
    if (( ${#unknown[@]} )); then
        warn "Not found in your configured repositories (sync with 'sudo pacman -Sy' or fix packages.txt):"
        printf '      %s\n' "${unknown[@]}" >&2
    fi
    if (( ${#installable[@]} )); then
        log "Missing packages (${#installable[@]}): ${installable[*]}"
        if ask "Install these with 'sudo pacman -S --needed'?"; then
            run sudo pacman -S --needed "${installable[@]}"
        else
            warn "Skipped package installation."
        fi
    fi
fi

# ------------------------------------------------------------------ summary
echo
if (( DRY_RUN )); then
    log "Dry run finished. Re-run without --dry-run to apply."
else
    log "Done."
fi
cat <<'EOF'
  Services (this script enables none; run what you need, once):
    sudo systemctl enable --now NetworkManager bluetooth upower
    sudo systemctl enable sddm          # only if you want a graphical login screen
  Next:      ./install-config.sh --dry-run   then   ./install-config.sh
EOF
(( ${#unknown[@]} == 0 )) || exit 1
