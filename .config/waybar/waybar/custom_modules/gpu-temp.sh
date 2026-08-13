#!/usr/bin/env bash

temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

printf '{"text":"󰢮  %s°C","tooltip":"GPU temperature: %s°C"}\n' "$temp" "$temp"
