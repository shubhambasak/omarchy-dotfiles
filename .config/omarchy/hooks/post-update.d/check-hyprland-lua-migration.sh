#!/bin/bash

# Notifies once when Hyprland's Lua config format becomes relevant:
#   - installed Hyprland reaches 0.57 (the version that drops .conf support), or
#   - Omarchy ships its own Lua-based default hypr configs
# Marker file prevents repeat notifications after the first hit.

MARKER="$HOME/.local/state/omarchy/hyprland-lua-migration-notified"
[[ -f $MARKER ]] && exit 0

mkdir -p "$(dirname "$MARKER")"

hypr_version=$(pacman -Q hyprland 2>/dev/null | awk '{print $2}' | cut -d- -f1)
omarchy_has_lua=false
find "$HOME/.local/share/omarchy/default/hypr" -iname '*.lua' -print -quit 2>/dev/null | grep -q . && omarchy_has_lua=true

hypr_at_or_past_057=false
if [[ -n $hypr_version ]]; then
  lowest=$(printf '%s\n0.57.0\n' "$hypr_version" | sort -V | head -1)
  [[ $lowest == "0.57.0" ]] && hypr_at_or_past_057=true
fi

if [[ $hypr_at_or_past_057 == true || $omarchy_has_lua == true ]]; then
  notify-send -u critical "Hyprland Lua config migration" \
    "Time to migrate ~/.config/hypr from .conf to Lua — ask Claude to do it. (Hyprland: ${hypr_version:-unknown}, Omarchy Lua defaults: $omarchy_has_lua)"
  touch "$MARKER"
fi
