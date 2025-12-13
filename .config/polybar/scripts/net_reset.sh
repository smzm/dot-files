#!/bin/bash


# ===========================================================
# To Allow user to restart vnstat and manage its database without password add these line to visude
# your_username ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop vnstat
# your_username ALL=(ALL) NOPASSWD: /usr/bin/systemctl start vnstat
# your_username ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart vnstat
# your_username ALL=(ALL) NOPASSWD: /usr/bin/rm -rf /var/lib/vnstat/*
# your_username ALL=(ALL) NOPASSWD: /usr/bin/vnstat
# ==========================================================

# 1. Ask for Confirmation
CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -p "⚠ Reset ALL Network Data?" -lines 2 -width 25)

if [ "$CONFIRM" == "Yes" ]; then
    
    # 2. Run commands directly with sudo (No password required now)
    
    sudo systemctl stop vnstat
    sudo rm -rf /var/lib/vnstat/*
    sudo systemctl start vnstat
    
    sleep 2
    
    # Detect Interfaces
    DEFAULT_IFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
    VPN_IFACE=$(ip link | grep -oP 'tun[0-9]+|wg[0-9]+' | head -n1)
    
    # Add them back (vnstat command needs sudo to talk to system-wide daemon in some setups, or just to be safe)
    if [ ! -z "$DEFAULT_IFACE" ]; then sudo vnstat --add -i $DEFAULT_IFACE; fi
    if [ ! -z "$VPN_IFACE" ]; then sudo vnstat --add -i $VPN_IFACE; fi
    
    sudo systemctl restart vnstat
    
    notify-send "Network Manager" "  tCounters reset to ZERO." -u normal

else
    exit 0
fi
