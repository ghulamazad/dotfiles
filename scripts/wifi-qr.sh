#!/usr/bin/env bash
# Make a "join this Wi-Fi" QR code (PNG) for a saved NetworkManager profile.
#   wifi-qr.sh make <connection-id>   write the PNG, print its path
#   wifi-qr.sh clear                  delete the PNG
#
# Security: the password is read from NetworkManager into a shell variable and
# piped to qrencode through stdin. It is never on a command line (where other
# users' `ps` could see it). The PNG contains the password in scannable form,
# so it is written 0600 into $XDG_RUNTIME_DIR (a per-user tmpfs, never on disk)
# and the panel deletes it as soon as the QR view closes.
set -euo pipefail
umask 077

out="${XDG_RUNTIME_DIR:-/tmp}/qs-wifi-qr.png"

esc() {   # backslash-escape the characters the WIFI: format treats as special
    local s=$1 ch
    # Backslash first, so the backslashes added below are not escaped again.
    # Replacement text goes through a quoted variable: unquoted `\\;` is not
    # reliable in bash substitutions (found by test).
    # shellcheck disable=SC1003  # a lone backslash in quotes is intended
    for ch in '\' ';' ',' ':' '"'; do
        s=${s//"$ch"/"\\$ch"}
    done
    printf '%s' "$s"
}

case "${1:-}" in
    clear) rm -f -- "$out"; exit 0 ;;
    make) ;;
    *) echo "usage: wifi-qr.sh make <connection-id> | clear" >&2; exit 2 ;;
esac

id="${2:?connection id required}"
command -v qrencode >/dev/null || { echo "qrencode is not installed (pacman -S qrencode)" >&2; exit 3; }

field() { nmcli -s -g "$1" connection show id "$id" 2>/dev/null || true; }

ssid="$(field 802-11-wireless.ssid)"
[[ -n "$ssid" ]] || { echo "not a Wi-Fi profile: $id" >&2; exit 4; }
km="$(field 802-11-wireless-security.key-mgmt)"

case "$km" in
    "")        payload="WIFI:T:nopass;S:$(esc "$ssid");;" ;;
    wpa-psk)   pw="$(field 802-11-wireless-security.psk)"
               payload="WIFI:T:WPA;S:$(esc "$ssid");P:$(esc "$pw");;" ;;
    sae)       pw="$(field 802-11-wireless-security.psk)"
               [[ -n "$pw" ]] || pw="$(field 802-11-wireless-security.sae-password)"
               payload="WIFI:T:SAE;S:$(esc "$ssid");P:$(esc "$pw");;" ;;
    *)         echo "unsupported security type: $km" >&2; exit 5 ;;
esac

printf '%s' "$payload" | qrencode -t PNG -s 8 -m 2 -o "$out"
printf '%s\n' "$out"
