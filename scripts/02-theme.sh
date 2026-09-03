#!/bin/bash
# Set Vantablack theme and install custom backgrounds.
# Uses omarchy commands — never touches ~/.config/omarchy/current/ directly.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

# 1. Copy custom Vantablack backgrounds into the user backgrounds dir.
#    omarchy theme bg next and the background selector both read from here.
DEST="$HOME/.config/omarchy/backgrounds/vantablack"
SRC="$REPO_DIR/.config/omarchy/backgrounds/vantablack"

mkdir -p "$DEST"
cp -r "$SRC/." "$DEST/"
ok "Custom Vantablack backgrounds installed ($(ls "$DEST" | wc -l) images)"

# 2. Install the Limine boot-menu theme-sync hook (recolors /boot/limine.conf
#    to match the active Omarchy theme on every `omarchy theme set`).
#    MUST happen before the `omarchy theme set` call below, or the very first
#    theme-set never triggers it (the hook doesn't exist yet at that point).
mkdir -p "$HOME/.config/omarchy/hooks/theme-set.d"
cp "$REPO_DIR/.config/omarchy/hooks/theme-set.d/limine-theme-sync.sh" \
  "$HOME/.config/omarchy/hooks/theme-set.d/limine-theme-sync.sh"
chmod 755 "$HOME/.config/omarchy/hooks/theme-set.d/limine-theme-sync.sh"
ok "Limine theme-sync hook installed"

# 3. Set theme via Omarchy's own command.
#    This wires up all symlinks in ~/.config/omarchy/current/ correctly, and
#    now also fires the theme-set hook installed above.
omarchy theme set Vantablack
ok "Theme set to Vantablack via omarchy"
