#!/bin/bash
# Apply Hyprland personalisation for Omarchy quattro (Lua config).
# Stock files (hyprland.conf-equivalent defaults, monitors.conf, etc. under
# /usr/share/omarchy) are left untouched — only our override files under
# ~/.config/hypr are copied, matching Omarchy's own "personal overrides"
# convention documented in a fresh hyprland.lua.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

SRC="$REPO_DIR/.config/hypr"
DEST="$HOME/.config/hypr"
mkdir -p "$DEST"

# hyprland.lua — entrypoint: loads personal overrides + 9 persistent workspaces
cp "$SRC/hyprland.lua" "$DEST/hyprland.lua"
ok "hyprland.lua (entrypoint + 9 persistent workspaces)"

# monitors.lua — scale=1 (correct for this 1080p 14" panel, not fractional/2x)
cp "$SRC/monitors.lua" "$DEST/monitors.lua"
ok "monitors.lua (scale 1, GDK_SCALE 1)"

# input.lua — sensitivity=0.35, natural scroll, 3-finger workspace swipe
cp "$SRC/input.lua" "$DEST/input.lua"
ok "input.lua (touchpad: sensitivity, natural scroll, gesture)"

# looknfeel.lua — window opacity 0.80/0.70 + blur (passes=9)
cp "$SRC/looknfeel.lua" "$DEST/looknfeel.lua"
ok "looknfeel.lua (opacity 0.80/0.70 + blur)"

# bindings.lua — all custom keybinds, Space-menu swap, SUPER+Q panel-close
cp "$SRC/bindings.lua" "$DEST/bindings.lua"
ok "bindings.lua (keybinds, Space swap, SUPER+Q)"

# autostart.lua — left at stock template; udiskie is now an Omarchy default
cp "$SRC/autostart.lua" "$DEST/autostart.lua"
ok "autostart.lua"

# Helper script bound to SUPER+Q: force-closes any open bar panel.
# Workaround for an Omarchy quattro bug where a second click on the same bar
# icon sometimes opens a different panel instead of closing the current one.
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/.local/bin/omarchy-hide-all-panels" "$HOME/.local/bin/omarchy-hide-all-panels"
chmod +x "$HOME/.local/bin/omarchy-hide-all-panels"
ok "omarchy-hide-all-panels (SUPER+Q bar-panel-close helper)"

# Global font, screensaver, and idle behavior — set via omarchy commands so
# the shell.json / fontconfig alias plumbing stays correct.
omarchy font set "Adwaita Mono" >/dev/null
ok "font set to Adwaita Mono (bar, lock screen, menus)"

omarchy toggle screensaver-off on >/dev/null
ok "screensaver disabled"

omarchy toggle idle stay-awake >/dev/null
ok "idle auto-lock disabled (stay-awake)"

hyprctl reload >/dev/null 2>&1 || true
ok "Hyprland config reloaded"
