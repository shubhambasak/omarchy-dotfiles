#!/bin/bash
# Create ~/.config/elephant/menus/ symlinks that omarchy reinstall misses.
# Without these, the Styles > Background and Styles > Theme menus in the
# omarchy launcher show nothing.
set -euo pipefail

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

ELEPHANT_SRC="$HOME/.local/share/omarchy/default/elephant"
MENUS_DIR="$HOME/.config/elephant/menus"

mkdir -p "$MENUS_DIR"
ok "~/.config/elephant/menus/ ready"

ln -snf "$ELEPHANT_SRC/omarchy_background_selector.lua" "$MENUS_DIR/omarchy_background_selector.lua"
ok "omarchy_background_selector linked"

ln -snf "$ELEPHANT_SRC/omarchy_themes.lua" "$MENUS_DIR/omarchy_themes.lua"
ok "omarchy_themes linked"

ln -snf "$ELEPHANT_SRC/omarchy_unlocks.lua" "$MENUS_DIR/omarchy_unlocks.lua"
ok "omarchy_unlocks linked"

# Restart elephant so it picks up the new modules immediately
pkill -x elephant 2>/dev/null || true
setsid uwsm-app -- elephant &>/dev/null &
sleep 1
ok "elephant restarted with new modules"
