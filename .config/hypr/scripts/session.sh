#!/usr/bin/env bash
# Usage:
#   session.sh save    <workspace> [name]
#   session.sh restore <workspace|name> [target_workspace]
#   session.sh list
#
# Env: FORCE_FLOAT=1  -> restore tiled windows as floating with saved size/pos

DIR="$HOME/.cache/sessions"; mkdir -p "$DIR"

usage() {
  echo "Usage: $0 save <ws> [name] | restore <ws|name> [target_ws] | list"
  exit 1
}

command -v jq >/dev/null || { echo "jq is required (sudo pacman -S jq)"; exit 1; }

# Find the launch command from a .desktop file matching the window class
desktop_cmd() {
  local class=${1,,} d f base wm line
  for d in "$HOME/.local/share/applications" \
           /usr/share/applications \
           /var/lib/flatpak/exports/share/applications \
           "$HOME/.local/share/flatpak/exports/share/applications"; do
    [ -d "$d" ] || continue
    for f in "$d"/*.desktop; do
      [ -e "$f" ] || continue
      base=$(basename "$f" .desktop); base=${base,,}
      wm=$(grep -m1 -i '^StartupWMClass=' "$f" | cut -d= -f2-); wm=${wm,,}
      if [ "$base" = "$class" ] || [ "$wm" = "$class" ]; then
        line=$(awk '/^\[Desktop Entry\]/{f=1;next} /^\[/{f=0}
                    f && /^Exec=/{sub(/^Exec=/,""); print; exit}' "$f")
        line=$(sed -E 's/ ?%[fFuUdDnNickvm]//g; s/%%/%/g' <<<"$line")
        [ -n "$line" ] && { echo "$line"; return 0; }
      fi
    done
  done
  return 1
}

# Command from /proc, safely quoted
proc_cmd() {
  local pid=$1 args=()
  [ -r "/proc/$pid/cmdline" ] || return 1
  mapfile -d '' -t args < "/proc/$pid/cmdline"
  [ "${#args[@]}" -gt 0 ] || return 1
  printf '%q ' "${args[@]}"
}

save() {
  local ws=$1 name=${2:-ws$1} file win pid class cmd
  [[ $ws =~ ^[0-9]+$ ]] || usage
  file="$DIR/$name.json"

  hyprctl clients -j \
  | jq -c --argjson ws "$ws" '
      .[] | select(.workspace.id == $ws)
      | {ws: .workspace.id, x: .at[0], y: .at[1],
         w: .size[0], h: .size[1], floating, pid, class}' \
  | while read -r win; do
      pid=$(jq -r .pid <<<"$win")
      class=$(jq -r .class <<<"$win")
      cmd=""
      # Chromium/Chrome/Brave/Edge/Vivaldi installed web apps: use .desktop file
      if [[ ${class,,} =~ ^(chrome|chromium|google-chrome|brave|msedge|vivaldi)- ]]; then
        cmd=$(desktop_cmd "$class")
      fi
      [ -z "$cmd" ] && cmd=$(proc_cmd "$pid")
      [ -z "$cmd" ] && cmd=$(desktop_cmd "$class")
      if [ -n "$cmd" ]; then
        jq -c --arg c "$cmd" '. + {cmd: $c}' <<<"$win"
      else
        echo "Skipped (no command found): $class" >&2
      fi
    done | jq -s 'sort_by(.x, .y)' > "$file"

  echo "Saved $(jq length "$file") window(s) from workspace $ws -> $file"
  notify-send "Workspace $ws saved" "$(jq length "$file") window(s)" 2>/dev/null
}

# Move a window to its workspace and, if floating, set size/position
apply_window() {
  local addr=$1 ws=$2 floating=$3 x=$4 y=$5 w=$6 h=$7
  local sel="address:$addr" cur cws cfloat
  cur=$(hyprctl clients -j | jq -r --arg a "$addr" \
        '.[] | select(.address == $a) | "\(.workspace.id) \(.floating)"')
  cws=${cur% *}; cfloat=${cur#* }

  if [ "$cws" != "$ws" ]; then
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\", follow = false, window = \"$sel\" })" >/dev/null
  fi

  if [ "$floating" = "true" ] || [ -n "${FORCE_FLOAT:-}" ]; then
    if [ "$cfloat" != "true" ]; then
      hyprctl dispatch "hl.dsp.window.float({ action = \"toggle\", window = \"$sel\" })" >/dev/null
    fi
    hyprctl dispatch "hl.dsp.window.resize({ window = \"$sel\", x = $w, y = $h, relative = false })" >/dev/null
    hyprctl dispatch "hl.dsp.window.move({ window = \"$sel\", x = $x, y = $y, relative = false })" >/dev/null
  fi
}

# Resize tiled windows to their saved size.
# Runs several passes because resizing one window shifts its neighbors.
fix_tiled_sizes() {
  local -n _addrs=$1 _ws=$2 _w=$3 _h=$4
  local pass i cur cw ch
  for pass in 1 2 3; do
    for i in "${!_addrs[@]}"; do
      cur=$(hyprctl clients -j | jq -r --arg a "${_addrs[$i]}" \
            '.[] | select(.address == $a) | "\(.size[0]) \(.size[1])"')
      [ -n "$cur" ] || continue
      cw=${cur% *}; ch=${cur#* }
      # skip if already within 1px of the saved size
      if (( cw - _w[i] > 1 || _w[i] - cw > 1 || ch - _h[i] > 1 || _h[i] - ch > 1 )); then
        hyprctl dispatch "hl.dsp.window.resize({ window = \"address:${_addrs[$i]}\", x = ${_w[$i]}, y = ${_h[$i]}, relative = false })" >/dev/null
      fi
    done
    sleep 0.2
  done
}

restore() {
  local name=$1 target=${2:-} file before addr i rules first_addr=""
  local ws x y w h floating class cmd
  local t_addr=() t_ws=() t_w=() t_h=()
  [[ $name =~ ^[0-9]+$ ]] && name="ws$name"
  file="$DIR/$name.json"
  [ -f "$file" ] || { echo "No session: $name"; exit 1; }
  [[ -z $target || $target =~ ^[0-9]+$ ]] || { echo "Target must be a number"; exit 1; }

  # focus the destination workspace so new windows/columns are added there in order
  hyprctl dispatch "hl.dsp.focus({ workspace = \"${target:-$(jq -r '.[0].ws' "$file")}\" })" >/dev/null
  sleep 0.3

  while IFS=$'\t' read -r ws x y w h floating class cmd <&3; do
    ws=${target:-$ws}
    before=$(hyprctl clients -j | jq -r '.[].address')

    rules="workspace = \"$ws\""
    if [ "$floating" = "true" ] || [ -n "${FORCE_FLOAT:-}" ]; then
      rules="$rules, float = true, size = {$w, $h}, move = {$x, $y}"
    fi
    hyprctl dispatch "hl.dsp.exec_cmd([==[$cmd]==], { $rules })" >/dev/null

    # wait (up to ~15 s) for the new window of this class, then fix its placement
    addr=""
    for i in $(seq 1 60); do
      addr=$(hyprctl clients -j \
             | jq -r --arg c "${class,,}" '.[] | select((.class | ascii_downcase) == $c) | .address' \
             | grep -vxFf <(printf '%s\n' "$before") | head -n1)
      [ -n "$addr" ] && break
      sleep 0.25
    done

    if [ -n "$addr" ]; then
      sleep 0.2
      apply_window "$addr" "$ws" "$floating" "$x" "$y" "$w" "$h"
      # remember the very first window we launched
      [ -z "$first_addr" ] && first_addr=$addr
      # remember tiled windows so we can resize them at the end
      if [ "$floating" != "true" ] && [ -z "${FORCE_FLOAT:-}" ]; then
        t_addr+=("$addr"); t_ws+=("$ws"); t_w+=("$w"); t_h+=("$h")
      fi
    else
      echo "Window did not appear: $class ($cmd)" >&2
    fi
  done 3< <(jq -r '.[] | [.ws,.x,.y,.w,.h,.floating,.class,.cmd] | @tsv' "$file")

  # all windows exist now, so tiled sizes can be set properly
  sleep 0.5
  fix_tiled_sizes t_addr t_ws t_w t_h

  # scroll the view back to the start by focusing the first tiled window
  # (falls back to the first window of any kind)
  local start=${t_addr[0]:-$first_addr}
  if [ -n "$start" ]; then
    sleep 0.2
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$start\" })" >/dev/null
  fi
}

case ${1:-} in
  save)    save "${2:-}" "${3:-}" ;;
  restore) restore "${2:-}" "${3:-}" ;;
  list)    ls "$DIR" | sed 's/\.json$//' ;;
  *)       usage ;;
esac
