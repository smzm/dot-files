#!/bin/bash
# waybar custom module: shows country flag + code based on public IP
# Requires: curl, jq

flag_emoji() {
    local cc="${1^^}"
    local flag=""
    local i hex
    for (( i=0; i<${#cc}; i++ )); do
        printf -v hex '%x' $(( $(printf '%d' "'${cc:i:1}") + 127397 ))
        flag+=$(printf "\U$hex")
    done
    echo "$flag"
}

response=$(curl -s -m 5 "http://ip-api.com/json/?fields=status,country,countryCode,query")

if [[ -z "$response" ]] || [[ "$(jq -r '.status' <<< "$response" 2>/dev/null)" != "success" ]]; then
    out='{"text":"","tooltip":"","class":"offline"}'
else
    country=$(jq -r '.country' <<< "$response")
    country_code=$(jq -r '.countryCode' <<< "$response")
    ip=$(jq -r '.query' <<< "$response")
    flag=$(flag_emoji "$country_code")
    out=$(jq -nc --arg text "$flag $country_code" --arg tooltip "Your IP is $ip ($country)" \
        '{text: $text, tooltip: $tooltip, class: "online"}')
fi

# tr strips any stray newline so waybar always gets exactly one line
tr -d '\n' <<< "$out"
echo
