#!/bin/bash

# --- CONFIGURATION ---
# List all interfaces that might carry internet traffic
# Based on your ip link: tun0 (VPN), enp5s0 (Ethernet), wlp4s0 (Wi-Fi)
INTERFACES="tun0 enp5s0 wlp4s0"
LIMIT_MIB=1024

# Colors
COLOR_SAFE="#757575"    
COLOR_WARN="#D1D1D1"    
COLOR_CRIT="#e53935"    

# Variable to store grand total
TOTAL_USAGE_MIB=0

# Loop through each interface and add up today's usage
for IFACE in $INTERFACES; do
    # Get one-line data for this interface
    # Suppress errors in case an interface (like tun0) is currently down/missing
    RAW_DATA=$(vnstat -i "$IFACE" --oneline 2>/dev/null)
    
    # If data exists for this interface
    if [ -n "$RAW_DATA" ]; then
        # Extract string (Field 6) e.g., "49.04 MiB" or "1.20 GiB"
        USAGE_STR=$(echo "$RAW_DATA" | cut -d';' -f6)
        
        VAL=$(echo "$USAGE_STR" | awk '{print $1}')
        UNIT=$(echo "$USAGE_STR" | awk '{print $2}')
        
        # Convert to MiB
        MIB_PART=$(awk -v val="$VAL" -v unit="$UNIT" 'BEGIN {
            if (unit == "GiB") print val * 1024;
            else if (unit == "KiB") print val / 1024;
            else if (unit == "B") print val / 1048576;
            else print val; 
        }')
        
        # Add to grand total (using awk for floating point addition)
        TOTAL_USAGE_MIB=$(awk -v total="$TOTAL_USAGE_MIB" -v part="$MIB_PART" 'BEGIN {print total + part}')
    fi
done

# Calculate Percentage of Limit
PERCENT=$(awk -v usage="$TOTAL_USAGE_MIB" -v limit="$LIMIT_MIB" 'BEGIN { 
    printf "%.0f", (usage/limit)*100 
}')

# Determine Color
if [ "$PERCENT" -ge 90 ]; then
    COLOR="$COLOR_CRIT"
elif [ "$PERCENT" -ge 75 ]; then
    COLOR="$COLOR_WARN"
else
    COLOR="$COLOR_SAFE"
fi

# Detect Current Active Interface for Label (Visual only)
# If tun0 is up, show "VPN", otherwise "NET"
if ip link show tun0 > /dev/null 2>&1 && ip link show tun0 | grep -q "LOWER_UP"; then
    # LABEL="VPN"
    LABEL=""
else
    # LABEL="NET"
    LABEL=""
fi

# Output
DISPLAY_MIB=$(printf "%.0f" "$TOTAL_USAGE_MIB")
echo "%{F$COLOR}${LABEL} ${DISPLAY_MIB} MiB ($PERCENT%)%{F-}"
