#!/usr/bin/env bash
# Usage:
#   session.sh save    <workspace> [name]
#   session.sh restore <workspace|name> [target_workspace]
#   session.sh list
#
# Env: FORCE_FLOAT=1  -> restore tiled windows as floating with saved size/pos
#
# Window groups (tabbed groups) are saved and restored too: members are
# re-launched, merged back into one group, in the same tab order, with the
# same tab active.

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

  # Some apps (Electron/Obsidian, ...) rewrite their process title, so the whole
  # command line shows up as ONE argument that contains spaces. Quoting that would
  # make a single bogus program name, so keep it as an ordinary shell line instead.
  local first=${args[0]}
  if [[ ${args[0]} == *" "* ]] && [ ! -e "${args[0]}" ]; then
    first=${args[0]%% *}
    # the program itself must exist, otherwise let the caller fall back to the .desktop file
    command -v -- "$first" >/dev/null || return 1
    printf '%s ' "${args[0]}"
    [ "${#args[@]}" -gt 1 ] && printf '%q ' "${args[@]:1}"
    return 0
  fi
  command -v -- "$first" >/dev/null || return 1
  printf '%q ' "${args[@]}"
}

save() {
  local ws=$1 name=${2:-ws$1} file win pid class cmd
  [[ $ws =~ ^[0-9]+$ ]] || usage
  file="$DIR/$name.json"

  # gid  = address of the group's first member (just a label shared by members),
  #        "-" when the window is not grouped
  # gidx = position of the window in the group's tab order
  # active = whether this is the visible tab of its group
  hyprctl clients -j \
  | jq -c --argjson ws "$ws" '
      .[] | select(.workspace.id == $ws)
      | .address as $addr
      | (.grouped // []) as $g
      | {ws: .workspace.id, x: .at[0], y: .at[1],
         w: .size[0], h: .size[1], floating, pid, class,
         gid:    (if ($g | length) > 0 then $g[0] else "-" end),
         gidx:   (if ($g | length) > 0 then ($g | index($addr)) else 0 end),
         active: ((.hidden // false) | not)}' \
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
    done | jq -s 'sort_by(.x, .y, .gid, .gidx)' > "$file"

  local groups
  groups=$(jq '[.[] | select(.gid != "-") | .gid] | unique | length' "$file")
  echo "Saved $(jq length "$file") window(s) ($groups group(s)) from workspace $ws -> $file"
  notify-send "Workspace $ws saved" "$(jq length "$file") window(s), $groups group(s)" 2>/dev/null
}

# Move a window to its workspace and, if floating, set size/position.
# Group members (8th arg = 1) are left alone: they take the group's geometry.
apply_window() {
  local addr=$1 ws=$2 floating=$3 x=$4 y=$5 w=$6 h=$7 member=${8:-0}
  local sel="address:$addr" cur cws cfloat
  cur=$(hyprctl clients -j | jq -r --arg a "$addr" \
        '.[] | select(.address == $a) | "\(.workspace.id) \(.floating)"')
  cws=${cur% *}; cfloat=${cur#* }

  if [ "$cws" != "$ws" ]; then
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\", follow = false, window = \"$sel\" })" >/dev/null
  fi

  [ "$member" = 1 ] && return 0

  if [ "$floating" = "true" ] || [ -n "${FORCE_FLOAT:-}" ]; then
    if [ "$cfloat" != "true" ]; then
      hyprctl dispatch "hl.dsp.window.float({ action = \"toggle\", window = \"$sel\" })" >/dev/null
    fi
    hyprctl dispatch "hl.dsp.window.resize({ window = \"$sel\", x = $w, y = $h, relative = false })" >/dev/null
    hyprctl dispatch "hl.dsp.window.move({ window = \"$sel\", x = $x, y = $y, relative = false })" >/dev/null
  fi
}

# How many windows are in this window's group (0 = not grouped)
group_size() {
  hyprctl clients -j | jq -r --arg a "$1" \
    '.[] | select(.address == $a) | (.grouped // []) | length'
}

# True if window $1 is in the same group as window $2
in_group_with() {
  hyprctl clients -j | jq -e --arg a "$1" --arg l "$2" \
    '.[] | select(.address == $a) | ((.grouped // []) | index($l)) != null' >/dev/null
}

# Address of the currently visible tab of the group that contains $1
group_visible() {
  hyprctl clients -j | jq -r --arg l "$1" \
    '[.[] | select(((.grouped // []) | index($l)) != null and (.hidden | not))][0].address // empty'
}

# Focus a window and confirm it really got focus
focus_window() {
  local a=$1 i
  for i in 1 2 3 4 5; do
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$a\" })" >/dev/null
    sleep 0.15
    [ "$(hyprctl activewindow -j | jq -r '.address')" = "$a" ] && return 0
  done
  return 1
}

# Focus the visible tab of the group containing $1 (a hidden tab can't be focused)
focus_group() {
  local vis
  vis=$(group_visible "$1")
  focus_window "${vis:-$1}"
}

# Make sure a freshly launched window ($1) ends up in the group containing $2.
# Normally it joins by itself (group:auto_group) because the group was focused
# when it launched. Otherwise push it into the group from each direction.
join_group() {
  local addr=$1 leader=$2 i d
  for i in 1 2 3 4 5 6 7 8; do
    in_group_with "$addr" "$leader" && return 0
    sleep 0.15
  done
  focus_group "$leader"
  for d in l r u d; do
    hyprctl dispatch "hl.dsp.window.move({ into_group = \"$d\", window = \"address:$addr\" })" >/dev/null
    sleep 0.2
    in_group_with "$addr" "$leader" && return 0
  done
  return 1
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
  local ws x y w h floating class gid active cmd member
  local t_addr=() t_ws=() t_w=() t_h=()
  # per-group bookkeeping (keyed by the saved group label)
  local -A g_leader=() g_count=() g_active=()
  [[ $name =~ ^[0-9]+$ ]] && name="ws$name"
  file="$DIR/$name.json"
  [ -f "$file" ] || { echo "No session: $name"; exit 1; }
  [[ -z $target || $target =~ ^[0-9]+$ ]] || { echo "Target must be a number"; exit 1; }

  # focus the destination workspace so new windows/columns are added there in order
  hyprctl dispatch "hl.dsp.focus({ workspace = \"${target:-$(jq -r '.[0].ws' "$file")}\" })" >/dev/null
  sleep 0.3

  # gid is "-" for ungrouped windows (keeps the TSV fields non-empty);
  # sessions saved before group support simply have no groups.
  while IFS=$'\t' read -r ws x y w h floating class gid active cmd <&3; do
    ws=${target:-$ws}
    before=$(hyprctl clients -j | jq -r '.[].address')

    # Is this window joining an already restored group?
    member=0
    if [ "$gid" != "-" ] && [ -n "${g_leader[$gid]:-}" ]; then
      member=1
      # focus the group's visible tab so the new window opens inside it
      focus_group "${g_leader[$gid]}" || echo "Could not focus group before launching $class" >&2
    fi

    rules="workspace = \"$ws\""
    if [ "$member" = 0 ] && { [ "$floating" = "true" ] || [ -n "${FORCE_FLOAT:-}" ]; }; then
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
      apply_window "$addr" "$ws" "$floating" "$x" "$y" "$w" "$h" "$member"
      # remember the very first window we launched
      [ -z "$first_addr" ] && first_addr=$addr

      if [ "$gid" != "-" ]; then
        if [ "$member" = 0 ]; then
          # first window of this group: turn it into a group
          hyprctl dispatch "hl.dsp.group.toggle({ window = \"address:$addr\" })" >/dev/null
          sleep 0.2
          g_leader[$gid]=$addr
          g_count[$gid]=1
        else
          join_group "$addr" "${g_leader[$gid]}" || echo "Could not merge into group: $class" >&2
          g_count[$gid]=$(( ${g_count[$gid]} + 1 ))
        fi
        # remember which tab was visible (1-based, in restore order)
        [ "$active" = "true" ] && g_active[$gid]=${g_count[$gid]}
      fi

      # remember tiled windows (group leaders only) so we can resize them at the end
      if [ "$member" = 0 ] && [ "$floating" != "true" ] && [ -z "${FORCE_FLOAT:-}" ]; then
        t_addr+=("$addr"); t_ws+=("$ws"); t_w+=("$w"); t_h+=("$h")
      fi
    else
      echo "Window did not appear: $class ($cmd)" >&2
    fi
  done 3< <(jq -r '.[] | [.ws,.x,.y,.w,.h,.floating,.class,(.gid // "-"),
                          (if .active == null then true else .active end),.cmd]
                        | map(tostring) | join("\t")' "$file")   # not @tsv: it doubles backslashes in cmd

  # all windows exist now, so tiled sizes can be set properly
  sleep 0.5
  fix_tiled_sizes t_addr t_ws t_w t_h

  # bring each group back to its saved visible tab
  for gid in "${!g_active[@]}"; do
    hyprctl dispatch "hl.dsp.group.active({ index = ${g_active[$gid]}, window = \"address:${g_leader[$gid]}\" })" >/dev/null
  done

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
