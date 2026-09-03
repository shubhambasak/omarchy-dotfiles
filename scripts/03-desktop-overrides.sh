#!/bin/bash
# Fix Omarchy quattro's app-drawer launch-or-focus bug for apps that declare
# DBusActivatable=true. The drawer launches everything via `gtk-launch
# <id>.desktop`; for an already-running D-Bus-activatable app that sends an
# Activate() call instead of spawning a process, which just re-presents the
# existing window rather than opening a new one — so trying to open a second
# Files/Power-Stats/Disks window from the drawer while one is already open
# silently does nothing (confirmed reproduced on Omarchy quattro).
#
# Fix: user-level .desktop overrides in ~/.local/share/applications/ win over
# the system ones (standard XDG lookup order) with that one line stripped.
# Generated fresh from the current system file each run rather than stored
# statically, so it survives upstream package updates.
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }

AFFECTED_APPS=(
  org.gnome.Nautilus      # Files
  org.gnome.PowerStats    # Power Statistics
  org.gnome.DiskUtility   # Disks
)

mkdir -p "$HOME/.local/share/applications"

for app in "${AFFECTED_APPS[@]}"; do
  SRC="/usr/share/applications/$app.desktop"
  DEST="$HOME/.local/share/applications/$app.desktop"
  if [[ -f "$SRC" ]]; then
    grep -v '^DBusActivatable=true$' "$SRC" > "$DEST"
    ok "$app.desktop override installed (DBusActivatable stripped)"
  else
    warn "$SRC not found — skipping $app (package not installed?)"
  fi
done

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
ok "desktop database updated"
