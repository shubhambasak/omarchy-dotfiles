#!/bin/bash
# Apply remaining personalisation: starship, tmux, walker.
# Note: hypridle is handled in 04-hyprland.sh alongside the other hypr files.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

# starship — shell prompt config
cp "$REPO_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
ok "starship.toml"

# tmux
mkdir -p "$HOME/.config/tmux"
cp "$REPO_DIR/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
ok "tmux/tmux.conf"

# walker — app launcher config
mkdir -p "$HOME/.config/walker"
cp "$REPO_DIR/.config/walker/config.toml" "$HOME/.config/walker/config.toml"
ok "walker/config.toml"
