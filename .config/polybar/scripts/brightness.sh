#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  Polybar Brightness Plugin — ddcutil
#  Scroll Up    → increase brightness by STEP
#  Scroll Down  → decrease brightness by STEP
#  Right Click  → reset (ddcutil setvcp 05 1)
# ─────────────────────────────────────────────

STEP="${BRIGHTNESS_STEP:-5}"
MIN=0
MAX=100

# State file — persists current value so we avoid
# a slow ddcutil getvcp call on every scroll tick
STATE_FILE="/tmp/.polybar_ddc_brightness"

# ── Icon ─────────────────────────────────────
ICON=$'\uf400'    # nf-oct-light_bulb
# ASCII fallback: ICON="*"

# ── Helpers ──────────────────────────────────

# Read current brightness from monitor via DDC.
# Caches result in STATE_FILE; falls back to 70 on error.
get_brightness() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
        return
    fi
    local raw
    raw=$(ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4}')
    local val="${raw:-70}"
    echo "$val" > "$STATE_FILE"
    echo "$val"
}

# Write brightness (VCP 10) and update cache.
set_brightness() {
    local val="$1"
    (( val < MIN )) && val=$MIN
    (( val > MAX )) && val=$MAX
    echo "$val" > "$STATE_FILE"
    ddcutil setvcp 10 "$val" --noverify 2>/dev/null &
}

# Reset via VCP 05 (factory reset for brightness),
# then resync cache from monitor.
reset_brightness() {
    ddcutil setvcp 05 1 --noverify 2>/dev/null
    rm -f "$STATE_FILE"
    # give monitor a moment, then re-read actual value
    sleep 0.4
    local raw
    raw=$(ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4}')
    echo "${raw:-70}" > "$STATE_FILE"
}

# ── Output (printed every polybar interval) ──
output() {
    local b
    b=$(get_brightness)
    printf "%s %d%%\n" "$ICON" "$b"
}

# ── Main ─────────────────────────────────────
case "${1:-}" in
    up)
        current=$(get_brightness)
        set_brightness $(( current + STEP ))
        ;;
    down)
        current=$(get_brightness)
        set_brightness $(( current - STEP ))
        ;;
    reset)
        reset_brightness
        ;;
    *)
        output
        ;;
esac
