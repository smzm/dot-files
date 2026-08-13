#!/usr/bin/env bash

# ============================================================
# Waybar Internet Usage Monitor
#
# Main display:
#   Today's internet usage
#
# Tooltip:
#   Today's usage
#   Cumulative usage
#   Cumulative package limit
#
# Daily usage resets automatically when the date changes.
# Cumulative usage continues across days.
# ============================================================

# Physical interfaces to monitor.
# Do NOT add VPN interfaces such as tun0/wg0.
INTERFACES="enp5s0 wlp4s0"

# ============================================================
# CONFIGURATION
# ============================================================

# CUMULATIVE package limit in GB.
#
# Example:
#   100 GB package -> LIMIT_GB=100
#   50 GB package  -> LIMIT_GB=50
#   1 GB package   -> LIMIT_GB=1
#
# This limit applies to CUMULATIVE usage, NOT daily usage.
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
# CURRENT DATE
# ============================================================

TODAY=$(date +%Y-%m-%d)

# ============================================================
# STATE
#
# File format:
#
# DATE 2026-08-13
#
# interface rx_bytes tx_bytes daily_bytes cumulative_bytes
#
# Example:
#
# DATE 2026-08-13
# enp5s0 123456 789012 500000000 12500000000
# wlp4s0 456789 123456 100000000 3000000000
# ============================================================

declare -A OLD_RX
declare -A OLD_TX
declare -A DAILY
declare -A CUMULATIVE

STATE_DATE=""

if [[ -f "$STATE_FILE" ]]; then

    while read -r FIELD1 FIELD2 FIELD3 FIELD4 FIELD5; do

        # ----------------------------------------------------
        # Date line
        # ----------------------------------------------------

        if [[ "$FIELD1" == "DATE" ]]; then
            STATE_DATE="$FIELD2"
            continue
        fi

        # Ignore empty lines
        [[ -z "$FIELD1" ]] && continue

        # ----------------------------------------------------
        # Current format:
        #
        # interface rx tx daily cumulative
        # ----------------------------------------------------

        if [[ -n "$FIELD5" ]]; then

            OLD_RX["$FIELD1"]="$FIELD2"
            OLD_TX["$FIELD1"]="$FIELD3"
            DAILY["$FIELD1"]="$FIELD4"
            CUMULATIVE["$FIELD1"]="$FIELD5"

        # ----------------------------------------------------
        # Compatibility with the previous script format:
        #
        # interface rx tx cumulative
        #
        # Existing cumulative usage is preserved.
        # Daily usage starts at zero.
        # ----------------------------------------------------

        elif [[ -n "$FIELD4" ]]; then

            OLD_RX["$FIELD1"]="$FIELD2"
            OLD_TX["$FIELD1"]="$FIELD3"
            DAILY["$FIELD1"]=0
            CUMULATIVE["$FIELD1"]="$FIELD4"

        fi

    done < "$STATE_FILE"

fi

# ============================================================
# MIDNIGHT / NEW DAY DETECTION
#
# If the saved date differs from today's date:
#
#   DAILY      -> reset to zero
#   CUMULATIVE -> keep unchanged
#
# This happens automatically on the first execution after
# midnight.
# ============================================================

if [[ -n "$STATE_DATE" && "$STATE_DATE" != "$TODAY" ]]; then

    for IFACE in $INTERFACES; do
        DAILY["$IFACE"]=0
    done

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

    OLD_DAILY="${DAILY[$IFACE]:-0}"
    OLD_CUMULATIVE="${CUMULATIVE[$IFACE]:-0}"

    # --------------------------------------------------------
    # First run for this interface
    #
    # Initialize the kernel counters.
    #
    # Traffic that happened before this script started is NOT
    # counted.
    # --------------------------------------------------------

    if [[ -z "$OLD_RX_VALUE" || -z "$OLD_TX_VALUE" ]]; then

        OLD_RX["$IFACE"]="$RX"
        OLD_TX["$IFACE"]="$TX"

        DAILY["$IFACE"]="$OLD_DAILY"
        CUMULATIVE["$IFACE"]="$OLD_CUMULATIVE"

        continue
    fi

    # --------------------------------------------------------
    # RX delta
    # --------------------------------------------------------

    if (( RX >= OLD_RX_VALUE )); then
        RX_DELTA=$((RX - OLD_RX_VALUE))
    else
        # Kernel counter was reset.
        RX_DELTA=$RX
    fi

    # --------------------------------------------------------
    # TX delta
    # --------------------------------------------------------

    if (( TX >= OLD_TX_VALUE )); then
        TX_DELTA=$((TX - OLD_TX_VALUE))
    else
        # Kernel counter was reset.
        TX_DELTA=$TX
    fi

    # --------------------------------------------------------
    # Total new traffic
    # --------------------------------------------------------

    DELTA=$((RX_DELTA + TX_DELTA))

    # --------------------------------------------------------
    # Update daily counter
    # --------------------------------------------------------

    DAILY["$IFACE"]=$((OLD_DAILY + DELTA))

    # --------------------------------------------------------
    # Update cumulative counter
    # --------------------------------------------------------

    CUMULATIVE["$IFACE"]=$((OLD_CUMULATIVE + DELTA))

    # --------------------------------------------------------
    # Save current kernel counters
    # --------------------------------------------------------

    OLD_RX["$IFACE"]="$RX"
    OLD_TX["$IFACE"]="$TX"

done

# ============================================================
# SAVE STATE
# ============================================================

TEMP_FILE="${STATE_FILE}.tmp"

: > "$TEMP_FILE"

# Save current date
printf 'DATE %s\n' "$TODAY" >> "$TEMP_FILE"

for IFACE in $INTERFACES; do

    [[ -z "${OLD_RX[$IFACE]:-}" ]] && continue

    printf '%s %s %s %s %s\n' \
        "$IFACE" \
        "${OLD_RX[$IFACE]}" \
        "${OLD_TX[$IFACE]}" \
        "${DAILY[$IFACE]:-0}" \
        "${CUMULATIVE[$IFACE]:-0}" \
        >> "$TEMP_FILE"

done

mv "$TEMP_FILE" "$STATE_FILE"

# ============================================================
# GRAND TOTALS
# ============================================================

DAILY_TOTAL_BYTES=0
CUMULATIVE_TOTAL_BYTES=0

for IFACE in $INTERFACES; do

    DAILY_TOTAL_BYTES=$(
        (
            echo "$DAILY_TOTAL_BYTES"
            echo "${DAILY[$IFACE]:-0}"
        ) |
        awk '{sum += $1} END {print sum + 0}'
    )

    CUMULATIVE_TOTAL_BYTES=$(
        (
            echo "$CUMULATIVE_TOTAL_BYTES"
            echo "${CUMULATIVE[$IFACE]:-0}"
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
#
# IMPORTANT:
# This is a CUMULATIVE package limit.
# ============================================================

LIMIT_BYTES=$((LIMIT_GB * 1000000000))

# ============================================================
# CUMULATIVE PERCENTAGE
#
# The package limit applies to cumulative usage.
#
# Example:
#
#   cumulative = 75 GB
#   limit      = 100 GB
#
#   percentage = 75%
# ============================================================

if (( LIMIT_BYTES > 0 )); then

    PERCENT=$(
        awk \
            -v usage="$CUMULATIVE_TOTAL_BYTES" \
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
# HUMAN-READABLE DAILY USAGE
# ============================================================

if (( DAILY_TOTAL_BYTES >= 1000000000 )); then

    DAILY_USAGE_DISPLAY=$(
        awk \
            -v bytes="$DAILY_TOTAL_BYTES" \
            'BEGIN {
                printf "%.2f GB", bytes / 1000000000
            }'
    )

else

    DAILY_USAGE_DISPLAY=$(
        awk \
            -v bytes="$DAILY_TOTAL_BYTES" \
            'BEGIN {
                printf "%.0f MB", bytes / 1000000
            }'
    )

fi

# ============================================================
# HUMAN-READABLE CUMULATIVE USAGE
# ============================================================

if (( CUMULATIVE_TOTAL_BYTES >= 1000000000 )); then

    CUMULATIVE_USAGE_DISPLAY=$(
        awk \
            -v bytes="$CUMULATIVE_TOTAL_BYTES" \
            'BEGIN {
                printf "%.2f GB", bytes / 1000000000
            }'
    )

else

    CUMULATIVE_USAGE_DISPLAY=$(
        awk \
            -v bytes="$CUMULATIVE_TOTAL_BYTES" \
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
#
# Main text:
#   Today's usage
#
# Tooltip:
#   Today's usage
#   Cumulative usage / package limit
#   Cumulative percentage
#   VPN status
# ============================================================

printf \
    '{"text":"%s %s","tooltip":"Today: %s\\n\\nCumulative: %s / %s\\nPercentage usage: %s%%\\n\\n%s\\n\\nReset cumulative counter with:\\n%s --reset","class":"network-usage","percentage":%d}\n' \
    "$LABEL" \
    "$DAILY_USAGE_DISPLAY" \
    "$DAILY_USAGE_DISPLAY" \
    "$CUMULATIVE_USAGE_DISPLAY" \
    "$LIMIT_DISPLAY" \
    "$PERCENT" \
    "$VPN_TEXT" \
    "$0" \
    "$DISPLAY_PERCENT"
