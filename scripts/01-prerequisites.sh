#!/bin/bash
# Check the system is a working Omarchy quattro install before we touch anything.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; exit 1; }
warn() { echo -e "  ${YELLOW}→${NC} $1"; }

# 1. Omarchy must be installed
command -v omarchy >/dev/null 2>&1 \
  || err "omarchy command not found. Run this on an Omarchy install."
ok "omarchy is installed"

# 2. Must be the package-backed quattro layout, not a legacy git-checkout install.
[[ -d "/usr/share/omarchy" ]] \
  || err "/usr/share/omarchy not found. This repo targets Omarchy quattro (package-backed) — run 'omarchy upgrade to quattro' first on legacy installs."
ok "/usr/share/omarchy present (package-backed quattro layout)"

# 3. Theme system must be working
[[ -f "$HOME/.local/state/omarchy/current/theme.name" ]] \
  || err "~/.local/state/omarchy/current/theme.name missing. Run: omarchy reinstall configs"
ok "omarchy theme system intact (current theme: $(cat "$HOME/.local/state/omarchy/current/theme.name"))"

# 4. Hyprland must be running (so hyprctl reload works at the end)
hyprctl version >/dev/null 2>&1 \
  || err "hyprctl not responding. Run this script from inside a Hyprland session."
ok "Hyprland is running"

# 5. Omarchy's own shell (bar/notifications/idle/lock/launcher) must be running —
#    04-hyprland.sh and 05-waybar.sh both call omarchy-toggle/omarchy-shell IPC.
pgrep -f "quickshell -n -p .*/omarchy/shell" >/dev/null 2>&1 \
  || warn "omarchy-shell doesn't appear to be running — idle/lock/panel toggles may no-op until it starts."

# 6. udiskie — warn if missing (disk automount is now an Omarchy default, but
#    only if the package is actually present)
if ! command -v udiskie >/dev/null 2>&1; then
  warn "udiskie not found — install it manually: omarchy pkg add udiskie"
else
  ok "udiskie is installed"
fi
