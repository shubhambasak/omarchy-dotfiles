#!/bin/bash
# Apply Waybar personalisation for Omarchy quattro.
# Quattro replaces waybar with its own Quickshell-based bar by default, so
# this reinstalls real waybar, restores our config on top of it, and hides
# the new bar (its process stays alive for notifications/idle/lock/launcher).
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

SRC="$REPO_DIR/.config/waybar"
DEST="$HOME/.config/waybar"

if ! command -v waybar >/dev/null 2>&1; then
  echo "  Installing waybar (removed by Omarchy quattro's default install)…"
  sudo pacman -S --needed --noconfirm waybar
fi
ok "waybar package installed"

mkdir -p "$DEST/scripts"
cp "$SRC/config.jsonc" "$DEST/config.jsonc"
ok "config.jsonc (cpu temp, agent icon, 9 workspaces, 12h clock, battery %)"

cp "$SRC/style.css" "$DEST/style.css"
ok "style.css (20px Adwaita Mono, matching spacing)"

cp "$SRC/scripts/cpu_temp_avg.sh" "$DEST/scripts/cpu_temp_avg.sh"
chmod +x "$DEST/scripts/cpu_temp_avg.sh"
ok "scripts/cpu_temp_avg.sh (CPU temperature for waybar)"

# Hide Omarchy's own bar — its Quickshell process stays running for
# notifications/idle/lock/launcher, only the bar UI itself is hidden.
omarchy toggle bar-off on >/dev/null 2>&1 || true
ok "Omarchy's own bar hidden (shell keeps running for panels/idle/lock)"

# Restart waybar to apply all changes
pkill -x waybar 2>/dev/null || true
sleep 1
setsid uwsm-app -- waybar &>/dev/null &
disown
sleep 1
pgrep -x waybar >/dev/null || { echo "  ✗ waybar failed to start"; exit 1; }
ok "waybar restarted"
