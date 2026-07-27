#!/bin/bash
# Apply Hyprland personalisation — only the files that differ from stock Omarchy.
# Stock files (hyprland.conf, monitors.conf, bindings.conf, hyprsunset.conf,
# xdph.conf) are left untouched so Omarchy's defaults and future updates apply.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

SRC="$REPO_DIR/.config/hypr"
DEST="$HOME/.config/hypr"

# autostart.conf — adds exec-once = udiskie (disk automount)
cp "$SRC/autostart.conf" "$DEST/autostart.conf"
ok "autostart.conf (udiskie autostart)"

# input.conf — kb_layout=us, sensitivity=0.35, natural scroll, 3-finger swipe
cp "$SRC/input.conf" "$DEST/input.conf"
ok "input.conf (touchpad: sensitivity, natural scroll, gesture)"

# looknfeel.conf — window opacity 0.80/0.70 + blur (passes=9)
cp "$SRC/looknfeel.conf" "$DEST/looknfeel.conf"
ok "looknfeel.conf (opacity 0.80/0.70 + blur)"

# hyprlock.conf — Adwaita Mono font for lock screen input field
cp "$SRC/hyprlock.conf" "$DEST/hyprlock.conf"
ok "hyprlock.conf (Adwaita Mono font)"

# hypridle.conf — screensaver and auto-lock timers disabled
cp "$SRC/hypridle.conf" "$DEST/hypridle.conf"
pkill -x hypridle 2>/dev/null || true
setsid uwsm-app -- hypridle &>/dev/null &
ok "hypridle.conf (screensaver + auto-lock disabled, daemon restarted)"
