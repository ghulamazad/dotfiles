#!/usr/bin/env bash
# system-info.sh: print the facts needed for a bug report or troubleshooting.
# Read-only; changes nothing. Paste the output when asking for help.
set -u

row() { printf '%-18s %s\n' "$1" "$2"; }
ver() { command -v "$1" >/dev/null 2>&1 && "$@" 2>&1 | head -n 1 || echo "not installed"; }

echo "== System =="
row "Kernel"        "$(uname -sr)"
row "Distro"        "$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-unknown}")"
row "Session type"  "${XDG_SESSION_TYPE:-unset}"
row "Compositor"    "${XDG_CURRENT_DESKTOP:-unset}"
row "Virtualized"   "$(systemd-detect-virt 2>/dev/null || echo unknown)"

echo
echo "== Versions =="
row "Hyprland"      "$(ver Hyprland --version)"
row "Quickshell"    "$(ver quickshell --version)"
row "Kitty"         "$(ver kitty --version)"
row "Neovim"        "$(ver nvim --version)"
row "Zsh"           "$(ver zsh --version)"

echo
echo "== Graphics =="
if command -v lspci >/dev/null 2>&1; then
    lspci 2>/dev/null | grep -Ei 'vga|3d|display' || echo "none found"
else
    echo "lspci not installed (pacman -S pciutils)"
fi
ls -l /dev/dri 2>/dev/null || echo "/dev/dri missing: no GPU device (3D acceleration off in the VM?)"

echo
echo "== Running shell components =="
for p in Hyprland quickshell hypridle hyprpolkitagent; do
    if pgrep -x "$p" >/dev/null 2>&1; then row "$p" "running"; else row "$p" "not running"; fi
done
