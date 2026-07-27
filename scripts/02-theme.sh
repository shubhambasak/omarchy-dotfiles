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

# 2. Set theme via Omarchy's own command.
#    This wires up all symlinks in ~/.config/omarchy/current/ correctly.
omarchy theme set Vantablack
ok "Theme set to Vantablack via omarchy"
