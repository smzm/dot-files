#!/usr/bin/env bash
# Portable Waybar brightness module.
# Usage: brightness.sh [show|up|down|reset|apply]
#
# Optional environment overrides:
#   BRIGHTNESS_STEP=5        percent per scroll tick
#   BRIGHTNESS_RESET=55      value used by "reset" (click)
#   BRIGHTNESS_MIN=0         lowest allowed value
#   BRIGHTNESS_SIGNAL=9      waybar "signal" number (SIGRTMIN+N)
#   BRIGHTNESS_BACKEND=      "backlight" or "ddc" (auto-detected if empty)
#   BRIGHTNESS_DISPLAY=      ddcutil display number (optional)
#   BRIGHTNESS_MODEL=        ddcutil monitor model, e.g. "Mi Monitor" (optional)
#   BRIGHTNESS_DDC_SLEEP=0.1 ddcutil --sleep-multiplier

STEP=${BRIGHTNESS_STEP:-5}
RESET=${BRIGHTNESS_RESET:-55}
MIN=${BRIGHTNESS_MIN:-0}
SIGNAL=${BRIGHTNESS_SIGNAL:-9}
DDC_SLEEP=${BRIGHTNESS_DDC_SLEEP:-0.1}

CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}
RUN_DIR=${XDG_RUNTIME_DIR:-/tmp}
STATE="$CACHE_DIR/waybar-brightness"          # desired value (persists across reboots)
APPLIED="$RUN_DIR/waybar-brightness.applied"  # last value written to hardware (cleared on reboot)
STATE_LOCK="$RUN_DIR/waybar-brightness.lock"
WORKER_LOCK="$RUN_DIR/waybar-brightness.worker"

ddc_args=()
[ -n "$BRIGHTNESS_DISPLAY" ] && ddc_args+=(--display "$BRIGHTNESS_DISPLAY")
[ -n "$BRIGHTNESS_MODEL" ]   && ddc_args+=(--model "$BRIGHTNESS_MODEL")

backend() {
    if [ -n "$BRIGHTNESS_BACKEND" ]; then echo "$BRIGHTNESS_BACKEND"
    elif command -v brightnessctl >/dev/null && compgen -G "/sys/class/backlight/*" >/dev/null; then echo backlight
    elif command -v ddcutil >/dev/null; then echo ddc
    fi
}

read_hw() {
    case $(backend) in
        backlight) brightnessctl -m 2>/dev/null | awk -F, 'NR==1{gsub(/%/,"",$4); print $4}' ;;
        ddc) ddcutil "${ddc_args[@]}" getvcp 10 -t 2>/dev/null \
               | awk '$1=="VCP" && $3=="C" && $5>0 {printf "%d", $4*100/$5}' ;;
    esac
}

write_hw() {
    case $(backend) in
        backlight) brightnessctl -q set "$1%" ;;
        ddc) ddcutil "${ddc_args[@]}" --sleep-multiplier "$DDC_SLEEP" setvcp 10 "$1" --noverify ;;
        *) return 1 ;;
    esac
}

verify_hw() {   # true if the hardware value is within 1 of $1
    local hw d
    hw=$(read_hw)
    [[ $hw =~ ^[0-9]+$ ]] || return 1
    d=$(( hw - $1 ))
    [ "${d#-}" -le 1 ]
}

# Current desired value: cache -> hardware -> 50
get_value() {
    local v
    v=$(cat "$STATE" 2>/dev/null)
    if ! [[ $v =~ ^[0-9]+$ ]]; then
        v=$(read_hw)
        [[ $v =~ ^[0-9]+$ ]] || v=50
        mkdir -p "$CACHE_DIR"
        echo "$v" > "$STATE"
        echo "$v" > "$APPLIED"   # came from hardware, nothing to restore
    fi
    echo "$v"
}

set_value() {   # $1 = new value; saved atomically
    mkdir -p "$CACHE_DIR"
    echo "$1" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
}

adjust() {      # $1 = delta; serialized so rapid scrolls don't clobber each other
    (
        flock 9
        v=$(( $(get_value) + $1 ))
        [ "$v" -gt 100 ] && v=100
        [ "$v" -lt "$MIN" ] && v=$MIN
        set_value "$v"
    ) 9>"$STATE_LOCK"
}

refresh_bar() { pkill -RTMIN+"$SIGNAL" -x waybar; }

spawn_apply() { setsid -f "$0" apply >/dev/null 2>&1 </dev/null; }

# Background worker: pushes the latest desired value to the hardware, verifies
# it, and retries with safer timing if the monitor ignored the write.
# If a worker is already running it picks up the newest value, so extra calls exit.
apply() {
    exec 8>"$WORKER_LOCK"
    flock -n 8 || return 0
    local tries=0 vtries=0 verified="" want
    while :; do
        want=$(cat "$STATE" 2>/dev/null)
        [ -z "$want" ] && break

        # 1) push the desired value if it hasn't been written yet
        if [ "$want" != "$(cat "$APPLIED" 2>/dev/null)" ]; then
            if write_hw "$want" >/dev/null 2>&1; then
                echo "$want" > "$APPLIED"; tries=0
            else
                tries=$((tries + 1)); [ "$tries" -ge 30 ] && break
                sleep 2
            fi
            continue
        fi

        # 2) written, but confirm the monitor really took it
        if [ "$verified" != "$want" ]; then
            sleep 0.5
            if verify_hw "$want" || [ "$vtries" -ge 4 ]; then
                verified=$want; vtries=0
            else
                vtries=$((vtries + 1))
                DDC_SLEEP=1            # retry with safer timing
                rm -f "$APPLIED"
            fi
            continue
        fi

        # 3) done; release the lock, but pick up any scroll that just arrived
        flock -u 8
        [ "$(cat "$STATE" 2>/dev/null)" = "$want" ] && break
        flock -n 8 || break
    done
}

case "${1:-show}" in
    show)
        v=$(get_value)
        echo "$v"
        [ -e "$APPLIED" ] || spawn_apply   # first run since boot: restore saved value
        ;;
    up)    adjust "$STEP";  refresh_bar; spawn_apply ;;
    down)  adjust "-$STEP"; refresh_bar; spawn_apply ;;
    reset) ( flock 9; set_value "$RESET" ) 9>"$STATE_LOCK"; refresh_bar; spawn_apply ;;
    apply) apply ;;
esac
