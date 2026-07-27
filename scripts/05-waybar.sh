#!/bin/bash
# Apply Waybar personalisation.
# Customisations: cpu temp module, 9 persistent workspaces, 12h clock,
# battery with %, Adwaita Mono font, cpu_temp_avg script.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

SRC="$REPO_DIR/.config/waybar"
DEST="$HOME/.config/waybar"

cp "$SRC/config.jsonc" "$DEST/config.jsonc"
ok "config.jsonc (cpu temp, 9 workspaces, 12h clock, battery %)"

cp "$SRC/style.css" "$DEST/style.css"
ok "style.css (Adwaita Mono font)"

mkdir -p "$DEST/scripts"
cp "$SRC/scripts/cpu_temp_avg.sh" "$DEST/scripts/cpu_temp_avg.sh"
chmod +x "$DEST/scripts/cpu_temp_avg.sh"
ok "scripts/cpu_temp_avg.sh (CPU temperature for waybar)"

# Restart waybar to apply all changes
omarchy restart waybar
sleep 1
pgrep -x waybar >/dev/null || { echo "  ✗ waybar failed to start"; exit 1; }
ok "waybar restarted"
