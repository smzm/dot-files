#!/usr/bin/env bash
# Portable Waybar brightness module.
# Usage: brightness.sh [show|up|down|reset|apply]

STEP=${BRIGHTNESS_STEP:-5}
RESET=${BRIGHTNESS_RESET:-55}
MIN=${BRIGHTNESS_MIN:-0}
SIGNAL=${BRIGHTNESS_SIGNAL:-9}
DDC_SLEEP=${BRIGHTNESS_DDC_SLEEP:-0.1}
RETRIES=${BRIGHTNESS_RETRIES:-30}              # max failed/ignored boot-sync attempts
SETTLE=${BRIGHTNESS_SETTLE:-5}                 # seconds between boot re-applies (0 = off)
SETTLE_PASSES=${BRIGHTNESS_SETTLE_PASSES:-3}   # number of delayed re-applies after boot
LOG=${BRIGHTNESS_LOG:-/tmp/waybar-brightness.log}

CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}
RUN_DIR=${XDG_RUNTIME_DIR:-/tmp}
STATE="$CACHE_DIR/waybar-brightness"          # desired value (persists across reboots)
APPLIED="$RUN_DIR/waybar-brightness.applied"  # tracks if hardware was synced this session
STATE_LOCK="$RUN_DIR/waybar-brightness.lock"
WORKER_LOCK="$RUN_DIR/waybar-brightness.worker"

log() { printf '%s [%s] %s\n' "$(date +%T.%3N)" "$$" "$*" >> "$LOG"; }

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

write_hw() {   # $1 = value, $2 = optional ddcutil sleep multiplier
    case $(backend) in
        backlight) brightnessctl -q set "$1%" ;;
        ddc) ddcutil "${ddc_args[@]}" --sleep-multiplier "${2:-$DDC_SLEEP}" setvcp 10 "$1" --noverify ;;
        *) return 1 ;;
    esac
}

# Some monitors remember the value across power cycles but only re-drive the
# backlight when the value actually CHANGES. Writing the same value is a no-op,
# so we first write a neighbouring value, then the real one.
# The step is 3 (not 1) so that a silently dropped second write is caught by
# the read-back check in apply(), and the pause is longer to give slow-waking
# monitors time to accept the first write.
nudge() {      # $1 = target value
    local alt=$(( $1 >= 97 ? $1 - 3 : $1 + 3 ))
    write_hw "$alt" 1 || return 1
    sleep 0.8
    write_hw "$1" 1
}

get_value() {
    local v
    v=$(cat "$STATE" 2>/dev/null)
    if ! [[ $v =~ ^[0-9]+$ ]]; then
        v=$(read_hw)
        [[ $v =~ ^[0-9]+$ ]] || v=50
        mkdir -p "$CACHE_DIR"
        echo "$v" > "$STATE"
    fi
    echo "$v"
}

set_value() {   # $1 = new value; saved atomically
    mkdir -p "$CACHE_DIR"
    echo "$1" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
}

adjust() {      # $1 = delta
    (
        flock 9
        v=$(( $(get_value) + $1 ))
        [ "$v" -gt 100 ] && v=100
        [ "$v" -lt "$MIN" ] && v=$MIN
        set_value "$v"
    ) 9>"$STATE_LOCK"
}

refresh_bar() { pkill -RTMIN+"$SIGNAL" -x waybar; }

# Background apply loop.
# First sync of a session (no $APPLIED yet): use nudge(), verify by read-back,
# retry if the monitor ignored it, then re-apply SETTLE_PASSES more times,
# SETTLE seconds apart.
apply() {
    exec 8>"$WORKER_LOCK"
    flock -n 8 || { log "apply: another worker is running, exiting"; exit 0; }

    local want got d i p ok tries=0 boot=0
    [ -e "$APPLIED" ] || boot=1
    log "apply start: backend=$(backend) boot=$boot want=$(cat "$STATE" 2>/dev/null)"

    while :; do
        want=$(cat "$STATE" 2>/dev/null)
        [ -z "$want" ] && break

        if [ "$want" != "$(cat "$APPLIED" 2>/dev/null)" ]; then
            ok=0
            if [ "$boot" = 1 ]; then
                nudge "$want" >/dev/null 2>>"$LOG" && ok=1
            else
                write_hw "$want" "$DDC_SLEEP" >/dev/null 2>>"$LOG" && ok=1
            fi

            if [ "$ok" = 1 ]; then
                if [ "$boot" = 1 ] && [ "$(backend)" = ddc ]; then
                    sleep 0.5
                    got=$(read_hw)
                    log "nudged to $want, read back '$got' (try $tries)"
                    [[ $got =~ ^[0-9]+$ ]] || got=-999
                    d=$(( got - want )); d=${d#-}
                    if [ "$d" -gt 1 ]; then          # monitor ignored it -> retry
                        tries=$((tries + 1))
                        [ "$tries" -ge "$RETRIES" ] && { log "giving up"; break; }
                        sleep 1
                        continue
                    fi
                fi
                echo "$want" > "$APPLIED"
                log "applied $want"
                tries=0

                if [ "$boot" = 1 ]; then
                    boot=0
                    for ((p = 1; p <= SETTLE_PASSES && SETTLE > 0; p++)); do
                        # Wait, but bail out of everything if the user scrolls meanwhile
                        for ((i = 0; i < SETTLE * 5; i++)); do
                            sleep 0.2
                            [ "$(cat "$STATE" 2>/dev/null)" != "$want" ] && break 2
                        done
                        nudge "$want" >/dev/null 2>>"$LOG"
                        log "settle re-apply $p/$SETTLE_PASSES -> $want"
                    done
                fi
            else
                tries=$((tries + 1))
                log "write failed (try $tries)"
                [ "$tries" -ge "$RETRIES" ] && { log "giving up"; break; }
                sleep 1
            fi
        else
            # Brief wait to catch a new scroll before exiting
            sleep 0.1
            [ "$(cat "$STATE" 2>/dev/null)" = "$(cat "$APPLIED" 2>/dev/null)" ] && break
        fi
    done
    log "apply end"
}

spawn_apply() {
    setsid -f "$0" apply >/dev/null 2>&1 </dev/null &
}

case "${1:-show}" in
    show)
        v=$(get_value)
        echo "$v"
        # Hardware not synced yet this boot session -> push it automatically
        if [ ! -e "$APPLIED" ]; then
            log "show: not applied yet, spawning apply"
            spawn_apply
        fi
        ;;
    up)
        adjust "$STEP"
        refresh_bar
        spawn_apply
        ;;
    down)
        adjust "-$STEP"
        refresh_bar
        spawn_apply
        ;;
    reset)
        ( flock 9; set_value "$RESET" ) 9>"$STATE_LOCK"
        refresh_bar
        spawn_apply
        ;;
    apply)
        log "invoked: apply (ppid=$PPID)"
        apply
        ;;
esac
