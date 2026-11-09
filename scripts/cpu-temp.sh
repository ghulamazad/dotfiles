#!/usr/bin/env bash
# cpu-temp.sh: print the CPU package temperature in degrees C, one decimal.
# Prints nothing (and exits 0) when no readable sensor exists, which is the
# normal case in a VM. Read-only; used by the Quickshell dashboard.
set -u

best=""
for zone in /sys/class/thermal/thermal_zone*; do
    [[ -r $zone/type && -r $zone/temp ]] || continue
    type="$(cat "$zone/type" 2>/dev/null)" || continue
    value="$(cat "$zone/temp" 2>/dev/null)" || continue
    [[ $value =~ ^[0-9]+$ ]] || continue
    # Intel package sensor is the best match; otherwise keep the first valid one.
    if [[ $type == x86_pkg_temp || $type == coretemp ]]; then
        best="$value"
        break
    fi
    [[ -z $best ]] && best="$value"
done

[[ -n $best ]] && awk -v v="$best" 'BEGIN { printf "%.1f\n", v / 1000 }'
exit 0
