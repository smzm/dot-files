#!/usr/bin/env bash

# ============================================================
# Waybar Internet Usage Monitor
# ============================================================

# Physical interfaces to monitor.
# Do NOT add VPN interfaces such as tun0/wg0.
INTERFACES="enp5s0 wlp4s0"

# ============================================================
# CONFIGURATION
# ============================================================

# Your internet package limit in GB.
#
# Example:
#   100 GB package -> LIMIT_GB=100
#   50 GB package  -> LIMIT_GB=50
#   1 GB package   -> LIMIT_GB=1
#
LIMIT_GB=100

# Persistent state file
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/waybar"
STATE_FILE="$STATE_DIR/net-usage.state"

# Icons
ICON_VPN="󰇚"
ICON_NET=""

# ============================================================
# RESET
# ============================================================

if [[ "$1" == "--reset" ]]; then
    rm -f "$STATE_FILE"

    echo "Network usage counter reset."
    exit 0
fi

# ============================================================
# PREPARE STATE DIRECTORY
# ============================================================

mkdir -p "$STATE_DIR"

# ============================================================
# STATE
#
# File format:
#
# interface rx_bytes tx_bytes cumulative_bytes
# ============================================================

declare -A OLD_RX
declare -A OLD_TX
declare -A TOTAL

if [[ -f "$STATE_FILE" ]]; then
    while read -r iface rx tx total; do
        [[ -z "$iface" ]] && continue

        OLD_RX["$iface"]="$rx"
        OLD_TX["$iface"]="$tx"
        TOTAL["$iface"]="$total"
    done < "$STATE_FILE"
fi

# ============================================================
# UPDATE COUNTERS
# ============================================================

for IFACE in $INTERFACES; do

    RX_FILE="/sys/class/net/$IFACE/statistics/rx_bytes"
    TX_FILE="/sys/class/net/$IFACE/statistics/tx_bytes"

    # Interface doesn't exist
    if [[ ! -f "$RX_FILE" || ! -f "$TX_FILE" ]]; then
        continue
    fi

    RX=$(<"$RX_FILE")
    TX=$(<"$TX_FILE")

    OLD_RX_VALUE="${OLD_RX[$IFACE]:-}"
    OLD_TX_VALUE="${OLD_TX[$IFACE]:-}"
    OLD_TOTAL="${TOTAL[$IFACE]:-0}"

    # --------------------------------------------------------
    # First run
    #
    # Initialize the counters but don't count traffic that
    # happened before this script was installed.
    # --------------------------------------------------------

    if [[ -z "$OLD_RX_VALUE" || -z "$OLD_TX_VALUE" ]]; then
        OLD_RX["$IFACE"]="$RX"
        OLD_TX["$IFACE"]="$TX"
        TOTAL["$IFACE"]="$OLD_TOTAL"
        continue
    fi

    # --------------------------------------------------------
    # Calculate RX delta
    # --------------------------------------------------------

    if (( RX >= OLD_RX_VALUE )); then
        RX_DELTA=$((RX - OLD_RX_VALUE))
    else
        # Counter was reset, probably after interface restart.
        RX_DELTA=$RX
    fi

    # --------------------------------------------------------
    # Calculate TX delta
    # --------------------------------------------------------

    if (( TX >= OLD_TX_VALUE )); then
        TX_DELTA=$((TX - OLD_TX_VALUE))
    else
        # Counter was reset, probably after interface restart.
        TX_DELTA=$TX
    fi

    # --------------------------------------------------------
    # Add new traffic
    # --------------------------------------------------------

    DELTA=$((RX_DELTA + TX_DELTA))

    TOTAL["$IFACE"]=$((OLD_TOTAL + DELTA))

    # Save current kernel counters
    OLD_RX["$IFACE"]="$RX"
    OLD_TX["$IFACE"]="$TX"

done

# ============================================================
# SAVE STATE
# ============================================================

TEMP_FILE="${STATE_FILE}.tmp"

: > "$TEMP_FILE"

for IFACE in $INTERFACES; do

    [[ -z "${OLD_RX[$IFACE]:-}" ]] && continue

    printf '%s %s %s %s\n' \
        "$IFACE" \
        "${OLD_RX[$IFACE]}" \
        "${OLD_TX[$IFACE]}" \
        "${TOTAL[$IFACE]:-0}" \
        >> "$TEMP_FILE"

done

mv "$TEMP_FILE" "$STATE_FILE"

# ============================================================
# GRAND TOTAL
# ============================================================

TOTAL_BYTES=0

for IFACE in $INTERFACES; do
    TOTAL_BYTES=$(
        (
            echo "$TOTAL_BYTES"
            echo "${TOTAL[$IFACE]:-0}"
        ) |
        awk '{sum += $1} END {print sum + 0}'
    )
done

# ============================================================
# PACKAGE LIMIT
#
# Decimal units:
#
# 1 MB = 1,000,000 bytes
# 1 GB = 1,000,000,000 bytes
# ============================================================

LIMIT_BYTES=$((LIMIT_GB * 1000000000))

# ============================================================
# PERCENTAGE
# ============================================================

if (( LIMIT_BYTES > 0 )); then
    PERCENT=$(
        awk \
            -v usage="$TOTAL_BYTES" \
            -v limit="$LIMIT_BYTES" \
            'BEGIN {
                printf "%.0f", (usage / limit) * 100
            }'
    )
else
    PERCENT=0
fi

# Waybar percentage should normally stay between 0 and 100.
DISPLAY_PERCENT="$PERCENT"

if (( DISPLAY_PERCENT < 0 )); then
    DISPLAY_PERCENT=0
fi

if (( DISPLAY_PERCENT > 100 )); then
    DISPLAY_PERCENT=100
fi

# ============================================================
# HUMAN-READABLE USAGE
# ============================================================

if (( TOTAL_BYTES >= 1000000000 )); then

    USAGE_DISPLAY=$(
        awk \
            -v bytes="$TOTAL_BYTES" \
            'BEGIN {
                printf "%.2f GB", bytes / 1000000000
            }'
    )

else

    USAGE_DISPLAY=$(
        awk \
            -v bytes="$TOTAL_BYTES" \
            'BEGIN {
                printf "%.0f MB", bytes / 1000000
            }'
    )

fi

# ============================================================
# HUMAN-READABLE LIMIT
# ============================================================

if (( LIMIT_BYTES >= 1000000000 )); then

    LIMIT_DISPLAY=$(
        awk \
            -v bytes="$LIMIT_BYTES" \
            'BEGIN {
                printf "%.2f GB", bytes / 1000000000
            }'
    )

else

    LIMIT_DISPLAY=$(
        awk \
            -v bytes="$LIMIT_BYTES" \
            'BEGIN {
                printf "%.0f MB", bytes / 1000000
            }'

    )

fi

# ============================================================
# VPN DETECTION
# ============================================================

if ip link show tun0 >/dev/null 2>&1 &&
   ip link show tun0 | grep -q "LOWER_UP"; then

    LABEL="$ICON_VPN"
    VPN_TEXT="VPN active"

else

    LABEL="$ICON_NET"
    VPN_TEXT="No VPN"

fi

# ============================================================
# WAYBAR JSON
# ============================================================

printf \
    '{"text":"%s %s","tooltip":"Internet usage: %s / %s\\nUsage: %s%%\\n%s\\n\\nReset with:\\n%s --reset","class":"network-usage","percentage":%d}\n' \
    "$LABEL" \
    "$USAGE_DISPLAY" \
    "$USAGE_DISPLAY" \
    "$LIMIT_DISPLAY" \
    "$PERCENT" \
    "$VPN_TEXT" \
    "$0" \
    "$DISPLAY_PERCENT"
