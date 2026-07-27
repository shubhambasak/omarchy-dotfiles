#!/bin/bash
# Check the system is a clean, working Omarchy install before we touch anything.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
ok()  { echo -e "  ${GREEN}✓${NC} $1"; }
err() { echo -e "  ${RED}✗${NC} $1"; exit 1; }

# 1. Omarchy must be installed
command -v omarchy >/dev/null 2>&1 \
  || err "omarchy command not found. Run this on an Omarchy install."
ok "omarchy is installed"

# 2. Omarchy source must exist
[[ -d "$HOME/.local/share/omarchy" ]] \
  || err "~/.local/share/omarchy not found. Is Omarchy installed correctly?"
ok "~/.local/share/omarchy present"

# 3. Theme system must be working
[[ -f "$HOME/.config/omarchy/current/theme.name" ]] \
  || err "~/.config/omarchy/current/theme.name missing. Run: omarchy reinstall configs"
ok "omarchy theme system intact (current theme: $(cat "$HOME/.config/omarchy/current/theme.name"))"

# 4. Hyprland must be running (so hyprctl reload works at the end)
hyprctl version >/dev/null 2>&1 \
  || err "hyprctl not responding. Run this script from inside a Hyprland session."
ok "Hyprland is running"

# 5. Elephant menus source files must exist (omarchy provides these)
ELEPHANT_SRC="$HOME/.local/share/omarchy/default/elephant"
[[ -f "$ELEPHANT_SRC/omarchy_background_selector.lua" ]] \
  || err "omarchy elephant modules not found at $ELEPHANT_SRC"
ok "omarchy elephant modules present"

# 6. udiskie — warn if missing (used for disk automount in autostart.conf)
if ! command -v udiskie >/dev/null 2>&1; then
  echo -e "  \033[1;33m→\033[0m udiskie not found — install it manually: omarchy pkg add udiskie"
  echo -e "  \033[1;33m→\033[0m Continuing anyway (Hyprland silently skips missing autostart binaries)"
else
  ok "udiskie is installed"
fi
