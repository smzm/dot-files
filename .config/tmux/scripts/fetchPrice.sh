#!/usr/bin/env bash

# Default token is BTC if no argument given
TOKEN=${1:-BTC}

# Fetch price
PRICE=$(curl -s "https://rate.sx/1${TOKEN}?rate")

# Format price to 2 decimals
PRICE_FORMATTED=$(printf "%.2f" "$PRICE")

# Output like BTC:80000.00
echo "${TOKEN} : ${PRICE_FORMATTED}"
