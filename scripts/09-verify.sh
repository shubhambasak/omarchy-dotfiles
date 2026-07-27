#!/bin/bash
# Verify the full system is clean and working after all personalisation is applied.
# This is the same checks that were done manually during the first setup session.
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
ok()  { echo -e "  ${GREEN}✓${NC} $1"; }
err() { echo -e "  ${RED}✗${NC} $1"; exit 1; }

# 1. Hyprland config must be error-free
hyprctl reload >/dev/null 2>&1
sleep 1
ERRORS="$(hyprctl configerrors 2>&1)"
[[ -z "$ERRORS" ]] || err "Hyprland config errors:\n$ERRORS"
ok "Hyprland config reloaded — no errors"

# 2. Omarchy theme system must still be intact
THEME_COUNT="$(omarchy theme list | wc -l)"
[[ "$THEME_COUNT" -gt 10 ]] \
  || err "omarchy theme list returned only $THEME_COUNT themes — something broke"
ok "omarchy theme list — $THEME_COUNT themes available"

CURRENT="$(omarchy theme current)"
[[ "$CURRENT" == "Vantablack" ]] \
  || err "Expected theme Vantablack, got: $CURRENT"
ok "omarchy theme current — Vantablack"

# 3. Background symlink must point to a real file
BG_LINK="$HOME/.config/omarchy/current/background"
[[ -L "$BG_LINK" && -f "$BG_LINK" ]] \
  || err "Background symlink is broken: $BG_LINK"
ok "Background symlink → $(readlink "$BG_LINK" | xargs basename)"

# 4. Waybar must be running
pgrep -x waybar >/dev/null \
  || err "waybar is not running"
ok "waybar is running"

# 5. Elephant menus must be wired up (Styles > Background / Theme menus)
[[ -L "$HOME/.config/elephant/menus/omarchy_background_selector.lua" ]] \
  || err "elephant menus not linked — run 03-elephant-menus.sh"
ok "elephant menus symlinks present"

# 6. cpu_temp_avg script must be executable
CPU_SCRIPT="$HOME/.config/waybar/scripts/cpu_temp_avg.sh"
[[ -x "$CPU_SCRIPT" ]] \
  || err "cpu_temp_avg.sh is not executable"
ok "waybar scripts/cpu_temp_avg.sh is executable"

# 7. Vantablack custom backgrounds must be in place
BG_DIR="$HOME/.config/omarchy/backgrounds/vantablack"
BG_COUNT="$(ls "$BG_DIR" 2>/dev/null | wc -l)"
[[ "$BG_COUNT" -ge 6 ]] \
  || err "Expected 6 custom Vantablack backgrounds, found $BG_COUNT"
ok "Custom Vantablack backgrounds — $BG_COUNT images"

# 8. Git identity must be set
GIT_NAME="$(git config --file "$HOME/.config/git/config" user.name 2>/dev/null || true)"
[[ -n "$GIT_NAME" ]] || err "git user.name not set in ~/.config/git/config"
ok "git identity — $GIT_NAME"

echo ""
ok "All checks passed. System is personalised and fully functional."
