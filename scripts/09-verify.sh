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

# 16. Desktop-launch overrides for DBusActivatable apps must be in place
for app in org.gnome.Nautilus org.gnome.PowerStats org.gnome.DiskUtility; do
  OVERRIDE="$HOME/.local/share/applications/$app.desktop"
  [[ -f "$OVERRIDE" ]] \
    || err "$OVERRIDE missing — run scripts/03-desktop-overrides.sh"
  ! grep -q '^DBusActivatable=true$' "$OVERRIDE" \
    || err "$OVERRIDE still has DBusActivatable=true — app-drawer second-window bug will recur"
done
ok "Desktop-launch overrides in place (Files/Power Stats/Disks second-window fix)"

# 17. omarchy-shell popup panel font size must be set
SHELL_TOML="$HOME/.config/omarchy/shell.toml"
grep -q "^base-size" "$SHELL_TOML" 2>/dev/null \
  || err "$SHELL_TOML missing base-size — popup panels (bluetooth/network/agents) will render too small"
ok "omarchy-shell popup panel font size set"

# 18. Terminal font sizes must agree with each other (foot as the reference)
FOOT_SIZE="$(sed -n 's/.*Adwaita Mono:size=\([0-9]*\).*/\1/p' "$HOME/.config/foot/foot.ini" | head -n1)"
KITTY_SIZE="$(sed -n 's/^font_size \([0-9.]*\).*/\1/p' "$HOME/.config/kitty/kitty.conf" | head -n1)"
GHOSTTY_SIZE="$(sed -n 's/^font-size = \([0-9]*\).*/\1/p' "$HOME/.config/ghostty/config" | head -n1)"
[[ -n "$FOOT_SIZE" && "${KITTY_SIZE%.*}" == "$FOOT_SIZE" && "$GHOSTTY_SIZE" == "$FOOT_SIZE" ]] \
  || err "Terminal font sizes disagree (foot=$FOOT_SIZE kitty=$KITTY_SIZE ghostty=$GHOSTTY_SIZE)"
ok "Terminal font sizes agree across foot/kitty/ghostty ($FOOT_SIZE)"

# 19. Icon theme must be a variant that actually exists (stock default
#     "Yaru-gray" doesn't, and renders broken icons everywhere)
ICON_THEME="$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")"
[[ "$ICON_THEME" == "Yaru-dark" ]] \
  || err "icon-theme is '$ICON_THEME', expected Yaru-dark"
ok "Icon theme — Yaru-dark"

# 20. Limine theme-sync hook must be installed and executable
LIMINE_HOOK="$HOME/.config/omarchy/hooks/theme-set.d/limine-theme-sync.sh"
[[ -x "$LIMINE_HOOK" ]] \
  || err "$LIMINE_HOOK missing or not executable — run scripts/02-theme.sh"
ok "Limine theme-sync hook installed"

echo ""
ok "All checks passed. System is personalised and fully functional."
