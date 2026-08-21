#!/bin/bash
# Verify the full system is clean and working after all personalisation is applied.
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
BG_LINK="$HOME/.local/state/omarchy/current/background"
[[ -L "$BG_LINK" && -f "$BG_LINK" ]] \
  || err "Background symlink is broken: $BG_LINK"
ok "Background symlink → $(readlink "$BG_LINK" | xargs basename)"

# 4. Waybar must be running (and its package must actually be installed —
#    Omarchy quattro doesn't ship it by default)
command -v waybar >/dev/null 2>&1 || err "waybar package not installed"
pgrep -x waybar >/dev/null || err "waybar is not running"
ok "waybar is installed and running"

# 5. Omarchy's own bar must be hidden (waybar is the visible one)
omarchy toggle enabled bar-off \
  || err "Omarchy's own bar is not hidden — run: omarchy toggle bar-off on"
ok "Omarchy's own bar is hidden"

# 6. cpu_temp_avg script must be executable
CPU_SCRIPT="$HOME/.config/waybar/scripts/cpu_temp_avg.sh"
[[ -x "$CPU_SCRIPT" ]] \
  || err "cpu_temp_avg.sh is not executable"
ok "waybar scripts/cpu_temp_avg.sh is executable"

# 7. SUPER+Q bar-panel-close helper must be in place
[[ -x "$HOME/.local/bin/omarchy-hide-all-panels" ]] \
  || err "~/.local/bin/omarchy-hide-all-panels missing or not executable"
ok "omarchy-hide-all-panels (SUPER+Q helper) is in place"

# 8. Vantablack custom backgrounds must be in place
BG_DIR="$HOME/.config/omarchy/backgrounds/vantablack"
BG_COUNT="$(ls "$BG_DIR" 2>/dev/null | wc -l)"
[[ "$BG_COUNT" -ge 6 ]] \
  || err "Expected 6 custom Vantablack backgrounds, found $BG_COUNT"
ok "Custom Vantablack backgrounds — $BG_COUNT images"

# 9. Font must be set to Adwaita Mono
FONT_CURRENT="$(omarchy font current)"
[[ "$FONT_CURRENT" == "Adwaita Mono" ]] \
  || err "Expected font Adwaita Mono, got: $FONT_CURRENT"
ok "omarchy font current — Adwaita Mono"

# 10. Screensaver and idle auto-lock must be disabled
omarchy toggle enabled screensaver-off \
  || err "Screensaver is not disabled — run: omarchy toggle screensaver-off on"
ok "Screensaver disabled"

IDLE_STATUS="$(omarchy toggle idle status | python3 -c 'import json,sys; print(json.load(sys.stdin)["enabled"])' 2>/dev/null || echo "unknown")"
[[ "$IDLE_STATUS" == "True" ]] \
  || err "Idle stay-awake is not enabled — run: omarchy toggle idle stay-awake"
ok "Idle auto-lock disabled (stay-awake)"

# 11. Git identity must be set
GIT_NAME="$(git config --file "$HOME/.config/git/config" user.name 2>/dev/null || true)"
[[ -n "$GIT_NAME" ]] || err "git user.name not set in ~/.config/git/config"
ok "git identity — $GIT_NAME"

# 12. Global gitignore must be installed and registered
[[ -f "$HOME/.gitignore_global" ]] \
  || err "~/.gitignore_global not found — run 07-git.sh"
EXCLUDES="$(git config --file "$HOME/.config/git/config" core.excludesfile 2>/dev/null || true)"
[[ -n "$EXCLUDES" ]] \
  || err "core.excludesfile not set in git config — run 07-git.sh"
ok "global gitignore registered ($EXCLUDES)"

# 13. Global pre-commit hook must be installed and executable
[[ -x "$HOME/.git-hooks/pre-commit" ]] \
  || err "~/.git-hooks/pre-commit not executable — run 07-git.sh"
HOOKS_PATH="$(git config --file "$HOME/.config/git/config" core.hooksPath 2>/dev/null || true)"
[[ -n "$HOOKS_PATH" ]] \
  || err "core.hooksPath not set in git config — run 07-git.sh"
ok "global pre-commit hook installed ($HOOKS_PATH)"

# 14. git-purge-ai must be available
[[ -x "$HOME/.local/bin/git-purge-ai" ]] \
  || err "~/.local/bin/git-purge-ai not executable — run 07-git.sh"
ok "git-purge-ai available"

# 15. git-filter-repo must be available (required by git-purge-ai)
[[ -x "$HOME/.local/bin/git-filter-repo" ]] \
  || err "~/.local/bin/git-filter-repo not found — run 07-git.sh"
ok "git-filter-repo available"

echo ""
ok "All checks passed. System is personalised and fully functional."
