#!/usr/bin/env bash
#
# waybar weather module
# Fully standalone: all configuration lives in this file, edit the block
# below and drop the script straight into your waybar config. No separate
# config file, env vars, or command-line flags are needed.
#
# Requires: bash >= 4, curl, jq, awk, GNU date (coreutils).
#
# Debug: WEATHER_DEBUG_OWM=1 ./weather.sh   -> prints a tooltip built from
#        fixed sample data (mirrors the Python script's debug path), useful
#        for tweaking fonts/sizes without hitting a real API.
# Debug: WEATHER_DEBUG_ALIGN=1 ./weather.sh -> prints a plain-text icon
#        alignment check for the daily-row font/icon combo. Use this to
#        recalibrate FA_ICONS padding whenever you change Font Awesome
#        versions -- glyph shapes (and therefore advance widths) can shift
#        between major versions even when the codepoint stays the same.

set -uo pipefail

# ============================================================================
# USER CONFIGURATION - edit the values below. Nothing outside this block
# needs to change for normal use.
# ============================================================================

declare -A CFG=(
    # Latitude / longitude of the location to report on (required).
    [lat]="36.2605"
    [lon]="59.6168"

    # Unit system: metric | standard (Kelvin) | imperial
    [units]="metric"

    # Data source: owm (OpenWeatherMap One Call 3.0) | meteo (Open-Meteo, free, no key)
    [backend]="meteo"

    # OpenWeatherMap API key. Required only when backend=owm.
    # Get one free at https://openweathermap.org/api (One Call API 3.0).
    [appid]=""

    # Optional: draw an N-character horizontal rule under the tooltip header.
    # Leave empty to use a blank line instead.
    [widthguard]=""

    # Optional: pango color name/hex for the widthguard rule.
    [guardcolor]="black"
)

# ============================================================================
# End of user configuration.
# ============================================================================

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

NERD_FONT="JetBrainsMono Nerd Font Mono"
# All body/monospace text now renders in the same Nerd Font as the hourly
# icons. Only FA_FONT below stays separate, since FA_ICONS are Font Awesome
# codepoints that only resolve correctly in a Font Awesome font.
MONO_FONT="$NERD_FONT"

# Font Awesome 7 Free, Solid style. Verify this resolves on your system with:
#   fc-list | grep -i "font awesome 7"
# If fc-match "Font Awesome 7 Free Solid" reports a different font, FA7
# either isn't installed or is registered under a different family string
# -- update FA_FONT to match whatever fc-list actually reports.
FA_FONT="Font Awesome 7 Free Solid"

HEADER_SIZE="12pt"
HEADER_ICON_SIZE="12pt"
DAILY_SIZE="12pt"

# Width-unit model for manual centering (see center_pad_units / the daily
# row block below). GTK tooltips ignore CSS text-align and this script's
# markup has no per-line alignment control, so "centering" a line inside a
# wider tooltip has to be done by padding it with non-breaking spaces.
#
# Because this is a monospace font, a fixed-width glyph's pixel advance
# scales ~linearly with point size, so "pt-units" (character_count * pt)
# are comparable across rows rendered at different sizes. The constant
# below is calibrated from the hourly block, which is built from three
# rows that are all internally consistent at 576 units (64 cells @ 9pt ==
# 32 cells @ 18pt) and is normally the widest thing in the tooltip.
#
# If your installed Nerd Font's icon glyphs are wider/narrower than a
# plain monospace cell, the daily rows may drift slightly off-center --
# nudge this number up/down until they line up, the same way
# WEATHER_DEBUG_ALIGN is used to recalibrate FA_ICONS padding.
TOOLTIP_TARGET_UNITS=576
DAILY_ROW_PT=14

# Non-breaking space (U+00A0, UTF-8 encoded). An ordinary space is a valid
# Pango line-break point; every tooltip row below that mixes text fields on
# one line uses NBSP as its separator/padding instead of " " so GTK can
# never wrap mid-row, regardless of tooltip width.
NBSP=$'\xc2\xa0'

declare -A WMO_DESCRIPTIONS=(
    [0]="clear sky"
    [1]="mainly clear"
    [2]="partly cloudy"
    [3]="overcast"
    [45]="fog"
    [48]="depositing rime fog"
    [51]="light drizzle"
    [53]="moderate drizzle"
    [55]="dense drizzle"
    [56]="light freezing drizzle"
    [57]="dense freezing drizzle"
    [61]="slight rain"
    [63]="moderate rain"
    [65]="heavy rain"
    [66]="light freezing rain"
    [67]="heavy freezing rain"
    [71]="slight snow fall"
    [73]="moderate snow fall"
    [75]="heavy snow fall"
    [77]="snow grains"
    [80]="slight rain showers"
    [81]="moderate rain showers"
    [82]="violent rain showers"
    [85]="slight snow showers"
    [86]="heavy snow showers"
    [95]="thunderstorm"
    [96]="thunderstorm with slight hail"
    [99]="thunderstorm with heavy hail"
)

# JetBrains Nerd Font icons (current + hourly)
declare -A JBN_ICONS=(
    [sun]="󰖙"
    [moon]="󰖔"
    [cloud]="󰖐"
    [cloud-bolt]="󰖓"
    [snowflake]="󰖘"
    [wind]="󰖝"
    [tornado]="󰼸"
    [temperature-low]="󰔄"
    [temperature-high]="󰔏"
    [smog]="󰖑"
    [cloud-sun-rain]="󰖗"
    [cloud-sun]="󰖕"
    [cloud-showers-water]="󰖖"
    [cloud-showers-heavy]="󰙿"
    [cloud-rain]="󰖖"
    [cloud-moon-rain]="󰼳"
    [cloud-moon]="󰼱"
    [default]="󰖐"
)

# Font Awesome 7 Free Solid icons (daily rows). Codepoints are unchanged
# from FA5/6 -> FA7 for every icon below (FA7's documented remaps only
# touch unrelated icons like user-alt/vector-square).
#
# The leading spaces are a manual alignment fudge: FA is a proportional
# icon font, so each glyph has a different advance width at 16pt, and
# these strings compensate so the daily rows line up against the
# surrounding monospace text. They're seeded from a known-good FA6
# calibration as a STARTING POINT ONLY -- FA7 redesigned some glyph
# shapes, which can shift advance width even at an unchanged codepoint.
# Recalibrate for your installed font with:
#   WEATHER_DEBUG_ALIGN=1 ./weather.sh
declare -A FA_ICONS=(
    [sun]="&#xf185;"
    [moon]="&#xf186;"
    [cloud]="&#xf0c2;"
    [cloud-bolt]="&#xf76c;"
    [snowflake]="&#xf2dc;"
    [wind]="&#xf72e;"
    [tornado]="&#xf76f;"
    [temperature-low]="&#xf76b;"
    [temperature-high]="&#xf769;"
    [smog]="&#xf75f;"
    [cloud-sun-rain]="&#xf743;"
    [cloud-sun]="&#xf6c4;"
    [cloud-showers-water]="&#xe4e4;"
    [cloud-showers-heavy]="&#xf740;"
    [cloud-rain]="&#xf73d;"
    [cloud-moon-rain]="&#xf73c;"
    [cloud-moon]="&#xf6c3;"
    [default]="  "
)

# Normalized weather state, populated by normalize_from_owm / normalize_from_meteo
# or by build_test_owm_data() in debug mode.
BACKEND=""
CURRENT_TEMP=""
CURRENT_DESC=""
CURRENT_ICON=""
CURRENT_CLASS=""
HOURLY_HOUR=(); HOURLY_TEMP=(); HOURLY_ICON=()
DAILY_DATE=(); DAILY_TMIN=(); DAILY_TMAX=(); DAILY_POP=(); DAILY_ICON=()
MINUTELY_TS=(); MINUTELY_PRECIP=()
ALERTS_TITLE=(); ALERTS_TIME=(); ALERTS_DESC=()

# ---------------------------------------------------------------------------
# Output / failure helper
# ---------------------------------------------------------------------------

fail_waybar() {
    local text="$1"
    local tooltip="${2:-$1}"
    local class="${3:-error}"
    jq -cn --arg text "$text" --arg class "$class" --arg alt "$text" --arg tooltip "$tooltip" \
        '{text: $text, class: $class, alt: $alt, tooltip: $tooltip}'
    exit 0
}

check_deps() {
    local missing=()
    local cmd
    for cmd in jq curl awk date; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if (( ${#missing[@]} > 0 )); then
        # jq itself might be the missing piece, so build this one JSON blob by hand.
        local msg="missing dependencies: ${missing[*]}"
        printf '{"text":"weather err","class":"error","alt":"%s","tooltip":"%s"}\n' "$msg" "$msg"
        exit 0
    fi
}

# ---------------------------------------------------------------------------
# Small utilities
# ---------------------------------------------------------------------------

vspace() {
    local size="${1:-8pt}"
    printf '<span color="black" size="%s"> </span>' "$size"
}

span_text() {
    local text="$1"
    local size="${2:-$DAILY_SIZE}"
    local font="${3:-$NERD_FONT}"
    printf '<span font_family="%s" size="%s">%s</span>' "$font" "$size" "$text"
}

urlencode() {
    printf '%s' "$1" | jq -sRr @uri
}

is_number() {
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

round_half_away_from_zero() {
    # awk-based rounding, since bash has no float math
    awk -v v="$1" 'BEGIN{printf "%d", (v>=0)?int(v+0.5):int(v-0.5)}'
}

ceil_num() {
    awk -v v="$1" 'BEGIN{c=int(v); if (v>c) c+=1; printf "%d", c}'
}

# Repeat NBSP $1 times.
nbsp_repeat() {
    local n="$1" out="" i
    for ((i = 0; i < n; i++)); do out+="$NBSP"; done
    printf '%s' "$out"
}

# Given a number of pt-units still needed ($1) and the point size the
# surrounding span will render at ($2), return an NBSP string that pads
# out roughly that many pt-units (rounded down to whole NBSP characters).
# Used to center a shorter/narrower line under a wider one -- see
# TOOLTIP_TARGET_UNITS above for the reasoning.
center_pad_units() {
    local units="$1" pt="$2" n
    if (( units <= 0 || pt <= 0 )); then
        printf ''
        return
    fi
    n=$(( units / pt ))
    (( n < 0 )) && n=0
    nbsp_repeat "$n"
}

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

validate_latitude() {
    is_number "$1" || return 1
    awk -v v="$1" 'BEGIN{exit !(v>=-90 && v<=90)}'
}

validate_longitude() {
    is_number "$1" || return 1
    awk -v v="$1" 'BEGIN{exit !(v>=-180 && v<=180)}'
}

validate_units() {
    case "${1,,}" in
        metric|standard|imperial) return 0 ;;
        *) return 1 ;;
    esac
}

validate_backend() {
    case "${1,,}" in
        owm|meteo) return 0 ;;
        *) return 1 ;;
    esac
}

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# Validates the CFG values set in the USER CONFIGURATION block at the top
# of this file. There is no external config file to read; everything lives
# in the CFG associative array declared above.
validate_config() {
    CFG[lat]="$(trim "${CFG[lat]:-}")"
    CFG[lon]="$(trim "${CFG[lon]:-}")"
    CFG[units]="$(trim "${CFG[units]:-metric}")"
    CFG[backend]="$(trim "${CFG[backend]:-owm}")"
    CFG[appid]="$(trim "${CFG[appid]:-}")"
    CFG[widthguard]="$(trim "${CFG[widthguard]:-}")"
    CFG[guardcolor]="$(trim "${CFG[guardcolor]:-black}")"

    if [[ -z "${CFG[lat]}" || -z "${CFG[lon]}" ]]; then
        fail_waybar "weather err" "Set CFG[lat] and CFG[lon] in the USER CONFIGURATION block at the top of this script"
    fi

    validate_latitude "${CFG[lat]}" || fail_waybar "weather err" "Invalid CFG[lat]: '${CFG[lat]}'"
    validate_longitude "${CFG[lon]}" || fail_waybar "weather err" "Invalid CFG[lon]: '${CFG[lon]}'"
    validate_units "${CFG[units]}" || fail_waybar "weather err" "Invalid CFG[units]: '${CFG[units]}'"
    validate_backend "${CFG[backend]}" || fail_waybar "weather err" "Invalid CFG[backend]: '${CFG[backend]}'"

    if [[ "${CFG[backend],,}" == "owm" && -z "${CFG[appid]}" ]]; then
        fail_waybar "weather err" "CFG[backend]=owm requires CFG[appid] to be set in the USER CONFIGURATION block"
    fi

    if [[ -n "${CFG[widthguard]}" && ! "${CFG[widthguard]}" =~ ^-?[0-9]+$ ]]; then
        fail_waybar "weather err" "Invalid CFG[widthguard]: '${CFG[widthguard]}' (must be an integer)"
    fi
}

# echoes the numeric width guard, or nothing (and fails) if unset/invalid
get_widthguard() {
    local val
    val="$(trim "${CFG[widthguard]:-}")"
    [[ -z "$val" ]] && return 1
    if [[ "$val" =~ ^-?[0-9]+$ ]]; then
        (( val < 0 )) && val=0
        printf '%s' "$val"
        return 0
    fi
    return 1
}

# ---------------------------------------------------------------------------
# Icon classification (mirrors classify_icon_status / _wmo + day/night variant)
# ---------------------------------------------------------------------------

classify_icon_status() {
    local code="$1"
    case "$code" in
        200|201|202|210|211|212|221|230|231|232) echo "cloud-bolt" ;;
        500|501|502|503|504) echo "cloud-sun-rain" ;;
        511) echo "snowflake" ;;
        520|521|531) echo "cloud-rain" ;;
        522) echo "cloud-showers-heavy" ;;
        600|601|602|611|612|613|615|616|620|621|622) echo "snowflake" ;;
        701|711|721|731|741|751|761|762) echo "smog" ;;
        771) echo "wind" ;;
        781) echo "tornado" ;;
        800) echo "sun" ;;
        801) echo "cloud-sun" ;;
        802|803|804) echo "cloud" ;;
        10001) echo "temperature-low" ;;
        10002) echo "temperature-high" ;;
        *) echo "default" ;;
    esac
}

classify_icon_status_wmo() {
    local code="$1"
    if (( code == 0 )); then echo "sun"
    elif (( code == 1 )); then echo "cloud-sun"
    elif (( code == 2 || code == 3 )); then echo "cloud"
    elif (( code == 45 || code == 48 )); then echo "smog"
    elif (( code == 51 || code == 53 || code == 55 || code == 56 || code == 57 || code == 61 || code == 63 )); then echo "cloud-sun-rain"
    elif (( code == 65 || code == 66 || code == 67 || code == 80 || code == 81 || code == 82 )); then echo "cloud-rain"
    elif (( code == 71 || code == 73 || code == 75 || code == 77 || code == 85 || code == 86 )); then echo "snowflake"
    elif (( code == 95 || code == 96 || code == 99 )); then echo "cloud-bolt"
    else echo "default"
    fi
}

apply_day_night_variant() {
    local status="$1" is_day="$2"
    case "$status" in
        sun)
            [[ "$is_day" == "1" ]] && echo "sun" || echo "moon"
            ;;
        cloud-sun)
            [[ "$is_day" == "1" ]] && echo "cloud-sun" || echo "cloud-moon"
            ;;
        cloud-sun-rain)
            [[ "$is_day" == "1" ]] && echo "cloud-sun-rain" || echo "cloud-moon-rain"
            ;;
        *)
            echo "$status"
            ;;
    esac
}

decode_icon_owm_jbn() {
    local status
    status="$(apply_day_night_variant "$(classify_icon_status "$1")" "$2")"
    printf '%s' "${JBN_ICONS[$status]:-${JBN_ICONS[default]}}"
}

decode_icon_owm_fa() {
    local status
    status="$(apply_day_night_variant "$(classify_icon_status "$1")" "$2")"
    printf '%s' "${FA_ICONS[$status]:-${FA_ICONS[default]}}"
}

decode_icon_wmo_jbn() {
    local status
    status="$(apply_day_night_variant "$(classify_icon_status_wmo "$1")" "$2")"
    printf '%s' "${JBN_ICONS[$status]:-${JBN_ICONS[default]}}"
}

decode_icon_wmo_fa() {
    local status
    status="$(apply_day_night_variant "$(classify_icon_status_wmo "$1")" "$2")"
    printf '%s' "${FA_ICONS[$status]:-${FA_ICONS[default]}}"
}

# ---------------------------------------------------------------------------
# URL building
# ---------------------------------------------------------------------------

build_owm_url() {
    printf 'https://api.openweathermap.org/data/3.0/onecall?lat=%s&lon=%s&units=%s&appid=%s' \
        "$(urlencode "${CFG[lat]}")" "$(urlencode "${CFG[lon]}")" \
        "$(urlencode "${CFG[units]}")" "$(urlencode "${CFG[appid]}")"
}

build_open_meteo_url() {
    local temp_unit precip_unit wind_unit
    if [[ "${CFG[units]}" == "imperial" ]]; then
        temp_unit="fahrenheit"; precip_unit="inch"; wind_unit="mph"
    else
        temp_unit="celsius"; precip_unit="mm"; wind_unit="kmh"
    fi
    printf 'https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&timezone=auto&forecast_days=8&current=temperature_2m,weather_code,is_day&hourly=temperature_2m,weather_code,is_day,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&temperature_unit=%s&precipitation_unit=%s&wind_speed_unit=%s' \
        "$(urlencode "${CFG[lat]}")" "$(urlencode "${CFG[lon]}")" \
        "$temp_unit" "$precip_unit" "$wind_unit"
}

# ---------------------------------------------------------------------------
# Fetching
# ---------------------------------------------------------------------------

# Sets HTTP_CODE and RAW_JSON_FILE (caller must rm the file when done).
http_get_json() {
    local url="$1"
    local body_file err_file
    body_file="$(mktemp)"
    err_file="$(mktemp)"

    local http_code
    http_code="$(curl -sS -A "waybar-weather" -m 20 -o "$body_file" -w '%{http_code}' "$url" 2>"$err_file")"
    local curl_exit=$?

    if (( curl_exit != 0 )); then
        local err_msg
        err_msg="$(cat "$err_file")"
        rm -f "$body_file" "$err_file"
        fail_waybar "weather net" "Network error: $err_msg" "network-error"
    fi
    rm -f "$err_file"

    HTTP_CODE="$http_code"
    RAW_JSON_FILE="$body_file"
}

fetch_weather() {
    local backend="${CFG[backend],,}"
    local url

    case "$backend" in
        owm)   url="$(build_owm_url)" ;;
        meteo) url="$(build_open_meteo_url)" ;;
        *)     fail_waybar "weather err" "Unsupported backend '$backend'" ;;
    esac

    http_get_json "$url"

    if (( HTTP_CODE >= 400 )); then
        local body
        body="$(cat "$RAW_JSON_FILE")"
        rm -f "$RAW_JSON_FILE"
        if [[ "$backend" == "owm" && "$HTTP_CODE" == "401" ]]; then
            fail_waybar "weather auth" "OpenWeather 401: check appid and One Call access" "auth-error"
        fi
        fail_waybar "weather err" "HTTP $HTTP_CODE: $body" "http-error"
    fi

    if ! jq -e . "$RAW_JSON_FILE" >/dev/null 2>&1; then
        rm -f "$RAW_JSON_FILE"
        fail_waybar "weather err" "Unexpected API response (invalid JSON)" "parse-error"
    fi
}

# ---------------------------------------------------------------------------
# Normalization: OWM One Call
# ---------------------------------------------------------------------------

normalize_from_owm() {
    local raw_file="$1"
    local interm
    interm="$(jq '{
        tz_offset: (.timezone_offset // 0),
        current_ts: .current.dt,
        current_code: .current.weather[0].id,
        current_desc: .current.weather[0].description,
        current_temp: .current.temp,
        hourly: [.hourly[0:16][] | {dt, temp, code: .weather[0].id}],
        daily_full: [.daily[] | {dt, sunrise, sunset}],
        daily: [.daily[0:8][] | {dt, temp_min: .temp.min, temp_max: .temp.max, pop: (.pop // 0), code: .weather[0].id}],
        minutely: [((.minutely // [])[0:60])[] | {dt, precipitation: (.precipitation // 0)}],
        alerts: [(.alerts // [])[] | {sender: (.sender_name // ""), event: (.event // "Alert"), start, end, description: (.description // "")}]
    }' "$raw_file")" || fail_waybar "weather err" "Unexpected API response. Missing key" "parse-error"

    local tz_offset current_ts current_code
    tz_offset="$(jq -r '.tz_offset' <<< "$interm")"
    current_ts="$(jq -r '.current_ts' <<< "$interm")"
    current_code="$(jq -r '.current_code' <<< "$interm")"
    CURRENT_DESC="$(jq -r '.current_desc' <<< "$interm")"
    CURRENT_TEMP="$(jq -r '.current_temp' <<< "$interm")"
    CURRENT_CLASS="$current_code"

    local today_sunrise today_sunset
    today_sunrise="$(jq -r '.daily_full[0].sunrise // empty' <<< "$interm")"
    today_sunset="$(jq -r '.daily_full[0].sunset // empty' <<< "$interm")"
    local current_is_day=0
    if [[ -n "$today_sunrise" && -n "$today_sunset" ]] \
        && (( current_ts >= today_sunrise && current_ts < today_sunset )); then
        current_is_day=1
    fi
    CURRENT_ICON="$(decode_icon_owm_fa "$current_code" "$current_is_day")"

    # lookup tables of (local date -> sunrise/sunset) for the day/night check
    local -a DF_DATE DF_SUNRISE DF_SUNSET
    local idx=0 ddt dsunrise dsunset local_epoch
    while IFS=$'\t' read -r ddt dsunrise dsunset; do
        local_epoch=$(( ddt + tz_offset ))
        DF_DATE[idx]="$(date -u -d "@$local_epoch" +%Y-%m-%d)"
        DF_SUNRISE[idx]="$dsunrise"
        DF_SUNSET[idx]="$dsunset"
        idx=$((idx + 1))
    done < <(jq -r '.daily_full[] | [.dt, .sunrise, .sunset] | @tsv' <<< "$interm")

    HOURLY_HOUR=(); HOURLY_TEMP=(); HOURLY_ICON=()
    local hts htemp hcode hour date_str is_day i
    while IFS=$'\t' read -r hts htemp hcode; do
        local_epoch=$(( hts + tz_offset ))
        hour="$(date -u -d "@$local_epoch" +%H)"; hour=$((10#$hour))
        date_str="$(date -u -d "@$local_epoch" +%Y-%m-%d)"
        if (( hour >= 6 && hour < 18 )); then is_day=1; else is_day=0; fi
        for ((i = 0; i < ${#DF_DATE[@]}; i++)); do
            if [[ "${DF_DATE[i]}" == "$date_str" ]]; then
                if (( hts >= DF_SUNRISE[i] && hts < DF_SUNSET[i] )); then
                    is_day=1
                else
                    is_day=0
                fi
                break
            fi
        done
        HOURLY_HOUR+=("$hour")
        HOURLY_TEMP+=("$htemp")
        HOURLY_ICON+=("$(decode_icon_owm_jbn "$hcode" "$is_day")")
    done < <(jq -r '.hourly[] | [.dt, .temp, .code] | @tsv' <<< "$interm")

    DAILY_DATE=(); DAILY_TMIN=(); DAILY_TMAX=(); DAILY_POP=(); DAILY_ICON=()
    local ddt2 dtmin dtmax dpop dcode date_fmt
    while IFS=$'\t' read -r ddt2 dtmin dtmax dpop dcode; do
        local_epoch=$(( ddt2 + tz_offset ))
        date_fmt="$(date -u -d "@$local_epoch" +'%a %b %d')"
        DAILY_DATE+=("$date_fmt")
        DAILY_TMIN+=("$dtmin")
        DAILY_TMAX+=("$dtmax")
        DAILY_POP+=("$dpop")
        DAILY_ICON+=("$(decode_icon_owm_fa "$dcode" 1)")
    done < <(jq -r '.daily[] | [.dt, .temp_min, .temp_max, .pop, .code] | @tsv' <<< "$interm")

    MINUTELY_TS=(); MINUTELY_PRECIP=()
    local mts mprecip
    while IFS=$'\t' read -r mts mprecip; do
        MINUTELY_TS+=("$mts")
        MINUTELY_PRECIP+=("$mprecip")
    done < <(jq -r '.minutely[] | [.dt, .precipitation] | @tsv' <<< "$interm")

    ALERTS_TITLE=(); ALERTS_TIME=(); ALERTS_DESC=()
    local sender event start end description title time_line start_fmt end_fmt
    while IFS=$'\t' read -r sender event start end description; do
        [[ "$sender" == "null" ]] && sender=""
        if [[ -n "$sender" ]]; then title="${sender}: ${event}"; else title="$event"; fi
        start_fmt=""; end_fmt=""
        [[ -n "$start" && "$start" != "null" ]] && start_fmt="$(date -d "@$start" +'%a %H:%M')"
        [[ -n "$end" && "$end" != "null" ]] && end_fmt="$(date -d "@$end" +'%a %H:%M')"
        if [[ -n "$start_fmt" && -n "$end_fmt" ]]; then
            time_line="${start_fmt} → ${end_fmt}"
        elif [[ -n "$start_fmt" ]]; then
            time_line="$start_fmt"
        elif [[ -n "$end_fmt" ]]; then
            time_line="$end_fmt"
        else
            time_line=""
        fi
        # Escape any raw markup-breaking characters from provider text
        # (alert titles/descriptions are free text and may legally contain
        # '&', '<', '>') before they get embedded in a <span> block.
        title="$(printf '%s' "$title" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')"
        description="$(printf '%s' "$description" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')"
        ALERTS_TITLE+=("$title")
        ALERTS_TIME+=("$time_line")
        ALERTS_DESC+=("$description")
    done < <(jq -r '.alerts[] | [.sender, .event, (.start // ""), (.end // ""), .description] | @tsv' <<< "$interm")

    BACKEND="owm"
}

# ---------------------------------------------------------------------------
# Normalization: Open-Meteo
# ---------------------------------------------------------------------------

normalize_from_meteo() {
    local raw_file="$1"
    local units="${CFG[units]}"

    local interm
    interm="$(jq '{
        current_time: .current.time,
        current_temp: .current.temperature_2m,
        current_code: .current.weather_code,
        current_is_day: (.current.is_day // 1),
        hourly_time: .hourly.time,
        hourly_temp: .hourly.temperature_2m,
        hourly_code: .hourly.weather_code,
        hourly_is_day: (.hourly.is_day // [range(0; (.hourly.time|length)) | 1]),
        daily_time: (.daily.time[0:8]),
        daily_code: (.daily.weather_code[0:8]),
        daily_tmin: (.daily.temperature_2m_min[0:8]),
        daily_tmax: (.daily.temperature_2m_max[0:8]),
        daily_pop: ((.daily.precipitation_probability_max // [range(0;(.daily.time|length))|0])[0:8])
    }' "$raw_file")" || fail_waybar "weather err" "Unexpected API response. Missing key" "parse-error"

    local current_time current_temp current_code current_is_day
    current_time="$(jq -r '.current_time' <<< "$interm")"
    current_temp="$(jq -r '.current_temp' <<< "$interm")"
    current_code="$(jq -r '.current_code' <<< "$interm")"
    current_is_day="$(jq -r '.current_is_day' <<< "$interm")"

    if [[ "$units" == "standard" ]]; then
        current_temp="$(awk -v t="$current_temp" 'BEGIN{printf "%.4f", t+273.15}')"
    fi

    CURRENT_TEMP="$current_temp"
    CURRENT_DESC="${WMO_DESCRIPTIONS[$current_code]:-weather}"
    CURRENT_ICON="$(decode_icon_wmo_fa "$current_code" "$current_is_day")"
    CURRENT_CLASS="wmo-${current_code}"

    local current_hour_floor current_hour_epoch
    current_hour_floor="$(date -d "$current_time" +'%Y-%m-%dT%H:00')"
    current_hour_epoch="$(date -d "$current_hour_floor" +%s)"

    local -a H_TIME H_TEMP H_CODE H_ISDAY
    local idx=0 t temp code isday
    while IFS=$'\t' read -r t temp code isday; do
        H_TIME[idx]="$t"; H_TEMP[idx]="$temp"; H_CODE[idx]="$code"; H_ISDAY[idx]="$isday"
        idx=$((idx + 1))
    done < <(jq -r '[.hourly_time, .hourly_temp, .hourly_code, .hourly_is_day] | transpose[] | @tsv' <<< "$interm")

    local start_idx=0 i t_epoch
    for ((i = 0; i < ${#H_TIME[@]}; i++)); do
        t_epoch="$(date -d "${H_TIME[i]}" +%s)"
        if (( t_epoch >= current_hour_epoch )); then
            start_idx=$i
            break
        fi
    done

    HOURLY_HOUR=(); HOURLY_TEMP=(); HOURLY_ICON=()
    local end_idx=$(( start_idx + 16 ))
    (( end_idx > ${#H_TIME[@]} )) && end_idx=${#H_TIME[@]}
    local hour htemp2
    for ((i = start_idx; i < end_idx; i++)); do
        hour="$(date -d "${H_TIME[i]}" +%H)"; hour=$((10#$hour))
        htemp2="${H_TEMP[i]}"
        if [[ "$units" == "standard" ]]; then
            htemp2="$(awk -v t="$htemp2" 'BEGIN{printf "%.4f", t+273.15}')"
        fi
        HOURLY_HOUR+=("$hour")
        HOURLY_TEMP+=("$htemp2")
        HOURLY_ICON+=("$(decode_icon_wmo_jbn "${H_CODE[i]}" "${H_ISDAY[i]}")")
    done

    DAILY_DATE=(); DAILY_TMIN=(); DAILY_TMAX=(); DAILY_POP=(); DAILY_ICON=()
    local dtime dcode dtmin dtmax dpop date_fmt pop_frac
    while IFS=$'\t' read -r dtime dcode dtmin dtmax dpop; do
        date_fmt="$(date -d "$dtime" +'%a %b %d')"
        if [[ "$units" == "standard" ]]; then
            dtmin="$(awk -v t="$dtmin" 'BEGIN{printf "%.4f", t+273.15}')"
            dtmax="$(awk -v t="$dtmax" 'BEGIN{printf "%.4f", t+273.15}')"
        fi
        pop_frac="$(awk -v p="$dpop" 'BEGIN{printf "%.4f", p/100}')"
        DAILY_DATE+=("$date_fmt")
        DAILY_TMIN+=("$dtmin")
        DAILY_TMAX+=("$dtmax")
        DAILY_POP+=("$pop_frac")
        DAILY_ICON+=("$(decode_icon_wmo_fa "$dcode" 1)")
    done < <(jq -r '[.daily_time, .daily_code, .daily_tmin, .daily_tmax, .daily_pop] | transpose[] | @tsv' <<< "$interm")

    MINUTELY_TS=(); MINUTELY_PRECIP=()
    ALERTS_TITLE=(); ALERTS_TIME=(); ALERTS_DESC=()

    BACKEND="meteo"
}

# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

format_temp() {
    local rounded
    rounded="$(round_half_away_from_zero "$1")"
    printf '%2d°' "$rounded"
}

format_pop() {
    local pct
    pct="$(awk -v p="$1" 'BEGIN{v=p*100; printf "%d", (v>=0)?int(v+0.5):int(v-0.5)}')"
    printf '%3d%%' "$pct"
}

# All hourly-row cells below pad with NBSP, never a plain space, so GTK's
# tooltip layout can't find a break opportunity mid-row no matter how the
# tooltip's rendered width compares to the row's natural width.

hourly_hour_cell() {
    local hour="$1" tens
    if (( hour >= 10 )); then tens=$(( hour / 10 )); else tens=" "; fi
    printf '%s%s%s%s' "$NBSP" "$tens" "$(( hour % 10 ))" "$NBSP"
}

hourly_temp_cell() {
    local text="$1" width=4 pad
    pad=$(( width - ${#text} ))
    (( pad < 0 )) && pad=0
    printf '%s%s' "$(nbsp_repeat "$pad")" "$text"
}

hourly_icon_cell() {
    local icon="$1" width=2 pad
    pad=$(( width - 1 ))  # icon glyph counts as 1 column
    (( pad < 0 )) && pad=0
    printf '%s%s' "$(nbsp_repeat "$pad")" "$icon"
}

render_hourly_hours() {
    local out="" n=${#HOURLY_HOUR[@]} i
    (( n > 16 )) && n=16
    for ((i = 0; i < n; i++)); do
        out+="$(hourly_hour_cell "${HOURLY_HOUR[i]}")"
    done
    span_text "$out" "9pt" "$NERD_FONT"
}

render_hourly_icons() {
    local out="" n=${#HOURLY_ICON[@]} i
    (( n > 16 )) && n=16
    for ((i = 0; i < n; i++)); do
        out+="$(hourly_icon_cell "${HOURLY_ICON[i]}")"
    done
    span_text "$out" "18pt" "$NERD_FONT"
}

render_hourly_temps() {
    local out="" n=${#HOURLY_TEMP[@]} i
    (( n > 16 )) && n=16
    for ((i = 0; i < n; i++)); do
        out+="$(hourly_temp_cell "$(format_temp "${HOURLY_TEMP[i]}")")"
    done
    span_text "$out" "9pt" "$NERD_FONT"
}

compute_daily_minmax() {
    local dmin="${DAILY_TMIN[0]}" dmax="${DAILY_TMAX[0]}" v
    for v in "${DAILY_TMIN[@]}"; do
        awk -v a="$v" -v b="$dmin" 'BEGIN{exit !(a<b)}' && dmin="$v"
    done
    for v in "${DAILY_TMAX[@]}"; do
        awk -v a="$v" -v b="$dmax" 'BEGIN{exit !(a>b)}' && dmax="$v"
    done
    printf '%s %s' "$dmin" "$dmax"
}

render_daily_bar() {
    # NBSP for the "off" steps instead of a plain space, for the same
    # anti-wrap reason as the hourly cells above.
    #
    # Bars are LEFT-ANCHORED: every row starts filling from column 0, and
    # only the fill LENGTH varies, scaled to how wide that day's min/max
    # spread is relative to the week's overall spread (dlow/dhigh). This
    # was previously a "floating" bar whose start column also moved based
    # on where day_min sat within the week range, which made same-width
    # ranges start at different x positions from row to row. Anchoring
    # the start keeps every row's bar beginning in the same column.
    local day_min="$1" day_max="$2" dlow="$3" dhigh="$4" steps="${5:-18}"
    awk -v day_min="$day_min" -v day_max="$day_max" -v dlow="$dlow" -v dhigh="$dhigh" -v steps="$steps" '
    BEGIN {
        delta = dhigh - dlow
        proportion = (delta != 0) ? (day_max - day_min) / delta : 1
        fillc = int(proportion * steps + 0.5)
        if (fillc < 1) fillc = 1
        if (fillc > steps) fillc = steps
        out = ""
        for (i = 0; i < steps; i++) {
            # NOTE: the parens around the ternary are load-bearing. Without
            # them, "out X ? A : B" parses as "(out X) ? A : B" -- string
            # concatenation binds tighter than ?: in awk, so the whole
            # expression collapses to a truthiness test and *replaces*
            # out each iteration instead of appending to it. That silently
            # turned this 18-character bar into a single leftover glyph.
            out = out ((i < fillc) ? "\xe2\x94\x80" : "\xc2\xa0")
        }
        printf "%s", out
    }'
}

big_daily_icon() {
    printf '<span font_family="%s" size="13pt" rise="-2pt">%s</span>' "$FA_FONT" "$1"
}

render_daily_rows() {
    local dlow dhigh
    read -r dlow dhigh < <(compute_daily_minmax)
    local rows=() n=${#DAILY_DATE[@]} i
    (( n > 8 )) && n=8
    local dt pop lt ht bar line nb
    local char_count units pad_units pad_left pad_right
    nb="$NBSP"
    for ((i = 0; i < n; i++)); do
        dt="${DAILY_DATE[i]}"
        pop="$(format_pop "${DAILY_POP[i]}")"
        lt="$(format_temp "${DAILY_TMIN[i]}")"
        ht="$(format_temp "${DAILY_TMAX[i]}")"
        bar="$(render_daily_bar "${DAILY_TMIN[i]}" "${DAILY_TMAX[i]}" "$dlow" "$dhigh")"
        line="${dt// /$nb}${nb}$(big_daily_icon "${DAILY_ICON[i]}")${nb}${pop}${nb}${lt}${nb}${bar}${nb}${ht}"

        # Center this row under the (usually wider) hourly block above by
        # padding both sides with NBSP. Everything on the line is DAILY_ROW_PT
        # except the icon glyph, which we treat as one plain column too --
        # close enough in practice; see TOOLTIP_TARGET_UNITS for tuning.
        char_count=$(( ${#dt} + 1 + 1 + 1 + ${#pop} + 1 + ${#lt} + 1 + ${#bar} + 1 + ${#ht} ))
        units=$(( char_count * DAILY_ROW_PT ))
        pad_units=$(( TOOLTIP_TARGET_UNITS - units ))
        if (( pad_units > 0 )); then
            pad_left=$(( pad_units / 2 ))
            pad_right=$(( pad_units - pad_left ))
        else
            pad_left=0
            pad_right=0
        fi
        line="$(center_pad_units "$pad_left" "$DAILY_ROW_PT")${line}$(center_pad_units "$pad_right" "$DAILY_ROW_PT")"

        rows+=("$(span_text "$line" "14pt" "$MONO_FONT")")
    done
    printf '%s\n' "${rows[@]}"
}

render_minutely_precip_chart() {
    local n=${#MINUTELY_TS[@]}
    (( n == 0 )) && return 0

    local -a icons=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
    local chart="" total="0" cap=$n i p pc
    (( cap > 60 )) && cap=60
    for ((i = 0; i < cap; i++)); do
        p="${MINUTELY_PRECIP[i]}"
        pc="$(ceil_num "$p")"
        (( pc > 8 )) && pc=8
        (( pc < 0 )) && pc=0
        chart+="${icons[pc]}"
        total="$(awk -v t="$total" -v p="$p" 'BEGIN{printf "%.6f", t+p}')"
    done

    awk -v t="$total" 'BEGIN{exit !(t==0)}' && return 0

    local first_ts="${MINUTELY_TS[0]}" first_minute
    first_minute="$(date -d "@$first_ts" +%M)"; first_minute=$((10#$first_minute))

    local -a seq=("15" "30" "45" " 0")
    local idx0=$(( first_minute / 15 ))
    local first_target="${seq[idx0]}"
    local first_target_num="${first_target// /}"
    [[ -z "$first_target_num" ]] && first_target_num=0
    local init_spaces=$(( first_target_num - first_minute ))

    local timelabel="$NBSP" j sidx
    for ((j = 0; j < init_spaces; j++)); do timelabel+="$NBSP"; done
    for ((j = 0; j < 4; j++)); do
        sidx=$(( (idx0 + j) % 4 ))
        timelabel+="${seq[sidx]//\ /$NBSP}"
        (( j < 3 )) && timelabel+="$(nbsp_repeat 13)"
    done

    printf '<span font_family="%s">%s%s%s</span>\n' "$MONO_FONT" "$NBSP$NBSP" "$chart" "$NBSP$NBSP"
    printf '<span font_family="%s">%s</span>\n' "$MONO_FONT" "$timelabel"
}

render_alerts() {
    local n=${#ALERTS_TITLE[@]}
    (( n == 0 )) && return 0

    local i title time_line description block
    for ((i = 0; i < n; i++)); do
        title="${ALERTS_TITLE[i]}"
        time_line="${ALERTS_TIME[i]}"
        description="${ALERTS_DESC[i]}"
        block="<span font_family=\"$MONO_FONT\" size=\"9pt\"><b>$title</b>"
        [[ -n "$time_line" ]] && block+=$'\n'"$time_line"
        [[ -n "$description" ]] && block+=$'\n\n'"$description"
        block+="</span>"
        printf '%s\n\n' "$block"
    done
}

tooltip_width_guard() {
    local chars="${1:-60}" size="${2:-10pt}" color="${3:-black}"
    local bar=""
    if (( chars > 0 )); then
        bar="$(printf '─%.0s' $(seq 1 "$chars"))"
    fi
    printf '<span font_family="%s" size="%s" color="%s">%s</span>' "$MONO_FONT" "$size" "$color" "$bar"
}

make_tooltip() {
    local wg
    wg="$(get_widthguard)" || wg=""
    local guard_color
    guard_color="$(trim "${CFG[guardcolor]:-black}")"

    local header
    header="$(printf '<span font_family="%s" size="%s">%s</span>%s%s<span font_family="%s" size="%s">%s</span>' \
        "$FA_FONT" "$HEADER_ICON_SIZE" "$CURRENT_ICON" "$NBSP" "$NBSP" "$MONO_FONT" "$HEADER_SIZE" "$CURRENT_DESC")"

    local precip_block=""
    [[ "$BACKEND" == "owm" ]] && precip_block="$(render_minutely_precip_chart)"

    local hourly_block
    hourly_block="$NBSP$(render_hourly_hours)$NBSP"$'\n'"$(render_hourly_icons)$NBSP"$'\n'"$NBSP$(render_hourly_temps)$NBSP"

    local daily_block
    daily_block="$(render_daily_rows)"

    local alerts_block=""
    [[ "$BACKEND" == "owm" ]] && alerts_block="$(render_alerts)"

    local -a parts=()
    parts+=("$header")

    if [[ -z "$wg" ]]; then
        parts+=("$(vspace "10pt")")
    else
        parts+=("$(tooltip_width_guard "$wg" "10pt" "$guard_color")")
    fi

    if [[ -n "$precip_block" ]]; then
        parts+=("$precip_block")
        parts+=("$(vspace "10pt")")
    fi

    parts+=("$hourly_block")
    parts+=("$(vspace "10pt")")
    parts+=("$daily_block")

    if [[ -n "$alerts_block" ]]; then
        parts+=("$(vspace "10pt")")
        parts+=("$alerts_block")
    fi

    local IFS=$'\n'
    printf '%s\n' "${parts[*]}"
}

# ---------------------------------------------------------------------------
# Debug / fixture data (WEATHER_DEBUG_OWM=1), mirrors build_test_owm_data()
# ---------------------------------------------------------------------------

build_test_owm_data() {
    BACKEND="owm"

    local now_epoch
    now_epoch="$(date -d "$(date +'%Y-%m-%d %H:00:00')" +%s)"

    local -a pattern=()
    local i
    for ((i = 0; i < 8; i++)); do pattern+=(0); done
    for ((i = 0; i < 6; i++)); do pattern+=(1); done
    for ((i = 0; i < 8; i++)); do pattern+=(2); done
    for ((i = 0; i < 8; i++)); do pattern+=(4); done
    for ((i = 0; i < 8; i++)); do pattern+=(6); done
    for ((i = 0; i < 6; i++)); do pattern+=(4); done
    for ((i = 0; i < 8; i++)); do pattern+=(2); done
    for ((i = 0; i < 4; i++)); do pattern+=(1); done
    for ((i = 0; i < 4; i++)); do pattern+=(0); done

    MINUTELY_TS=(); MINUTELY_PRECIP=()
    for ((i = 0; i < ${#pattern[@]} && i < 60; i++)); do
        MINUTELY_TS+=("$(( now_epoch + i * 60 ))")
        MINUTELY_PRECIP+=("${pattern[i]}")
    done

    local -a hourly_status=(cloud cloud cloud-rain cloud-rain cloud-showers-heavy cloud-rain cloud cloud-moon moon moon cloud-moon cloud-moon-rain cloud-rain cloud cloud-sun sun)
    local -a temps=(48 47 46 45 44 43 42 40 39 38 39 41 44 47 50 53)

    HOURLY_HOUR=(); HOURLY_TEMP=(); HOURLY_ICON=()
    local hepoch hour
    for ((i = 0; i < 16; i++)); do
        hepoch=$(( now_epoch + i * 3600 ))
        hour="$(date -d "@$hepoch" +%H)"; hour=$((10#$hour))
        HOURLY_HOUR+=("$hour")
        HOURLY_TEMP+=("${temps[i]}")
        HOURLY_ICON+=("${JBN_ICONS[${hourly_status[i]}]}")
    done

    local -a daily_status=(sun cloud-sun cloud cloud-rain cloud-showers-heavy cloud-rain cloud sun)
    local -a daily_tmin=(41 43 45 49 50 46 39 37)
    local -a daily_tmax=(58 61 63 60 57 54 51 55)
    local -a daily_pop=(0.05 0.15 0.25 0.70 0.90 0.65 0.20 0.00)

    DAILY_DATE=(); DAILY_TMIN=(); DAILY_TMAX=(); DAILY_POP=(); DAILY_ICON=()
    local depoch date_fmt
    for ((i = 0; i < 8; i++)); do
        depoch=$(( now_epoch + i * 86400 ))
        date_fmt="$(date -d "@$depoch" +'%a %b %d')"
        DAILY_DATE+=("$date_fmt")
        DAILY_TMIN+=("${daily_tmin[i]}")
        DAILY_TMAX+=("${daily_tmax[i]}")
        DAILY_POP+=("${daily_pop[i]}")
        DAILY_ICON+=("${FA_ICONS[${daily_status[i]}]}")
    done

    ALERTS_TITLE=("National Weather Service: Wind Advisory" "National Weather Service: Flood Watch")
    ALERTS_TIME=("Today 14:00 → Today 23:00" "Tonight 21:00 → Tomorrow 10:00")
    ALERTS_DESC=(
        $'Southwest winds 20 to 30 mph with gusts up to 50 mph expected.\nLoose outdoor objects may be blown around. Tree limbs could be blown down.'
        $'Periods of heavy rainfall may lead to localized flooding in low-lying areas.\nMonitor later forecasts and be prepared to take action if warnings are issued.'
    )

    CURRENT_TEMP=51
    CURRENT_DESC="light rain"
    CURRENT_ICON="${FA_ICONS[cloud-rain]}"
    CURRENT_CLASS="500"
}

debug_dump_test_tooltip() {
    build_test_owm_data
    local unit_symbol="°F"
    local rounded_temp
    rounded_temp="$(round_half_away_from_zero "$CURRENT_TEMP")"
    local text="${CURRENT_ICON} ${rounded_temp} ${unit_symbol}"
    local tooltip
    tooltip="$(make_tooltip)"
    jq -cn --arg text "$text" --arg class "$CURRENT_CLASS" --arg alt "$CURRENT_DESC" --arg tooltip "$tooltip" \
        '{text: $text, class: $class, alt: $alt, tooltip: $tooltip}'
}

# One-off manual alignment check for the daily-row icons, ported from
# __align_test__render_daily_rows(). Not wired into normal output; run with
# WEATHER_DEBUG_ALIGN=1 to print it as plain text. Use this to recalibrate
# FA_ICONS padding whenever the installed Font Awesome version changes.
debug_align_test_daily_rows() {
    local -a names=(sun moon cloud cloud-bolt snowflake wind tornado temperature-low temperature-high smog cloud-sun-rain cloud-sun cloud-showers-water cloud-showers-heavy cloud-rain cloud-moon-rain cloud-moon)
    local name
    for name in "${names[@]}"; do
        span_text "AAA $(big_daily_icon "${FA_ICONS[$name]}") BBB | $name" "14pt" "$MONO_FONT"
        printf '\n'
    done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

temp_unit_symbol() {
    case "$1" in
        imperial) printf '°F' ;;
        standard) printf 'K' ;;
        *) printf '°C' ;;
    esac
}

main() {
    check_deps

    if [[ "${WEATHER_DEBUG_ALIGN:-0}" == "1" ]]; then
        debug_align_test_daily_rows
        return
    fi

    if [[ "${WEATHER_DEBUG_OWM:-0}" == "1" ]]; then
        debug_dump_test_tooltip
        return
    fi

    validate_config
    fetch_weather

    local backend="${CFG[backend],,}"
    if [[ "$backend" == "owm" ]]; then
        normalize_from_owm "$RAW_JSON_FILE"
    else
        normalize_from_meteo "$RAW_JSON_FILE"
    fi
    rm -f "$RAW_JSON_FILE"

    local unit_symbol
    unit_symbol="$(temp_unit_symbol "${CFG[units]}")"

    local rounded_temp
    rounded_temp="$(round_half_away_from_zero "$CURRENT_TEMP")"

    local text="${CURRENT_ICON}  ${rounded_temp} ${unit_symbol}"
    local tooltip
    tooltip="$(make_tooltip)"

    jq -cn --arg text "$text" --arg class "$CURRENT_CLASS" --arg alt "$CURRENT_DESC" --arg tooltip "$tooltip" \
        '{text: $text, class: $class, alt: $alt, tooltip: $tooltip}'
}

main "$@"
