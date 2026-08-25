#!/bin/bash
# Apply remaining personalisation: starship, tmux, terminal fonts, GTK/Nautilus.
# Note: hypridle/hyprlock/walker no longer exist under Omarchy quattro — their
# personalisation moved to 04-hyprland.sh (omarchy toggle commands) and
# omarchy-shell's own menu system respectively.
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

# Terminal fonts — Adwaita Mono at size 15, tuned for this panel's actual
# pixel density (not a naive "double everything" from a stock 1x assumption).
mkdir -p "$HOME/.config/alacritty" "$HOME/.config/kitty" "$HOME/.config/ghostty" "$HOME/.config/foot"
cp "$REPO_DIR/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
cp "$REPO_DIR/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$REPO_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
cp "$REPO_DIR/.config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
ok "terminal fonts (alacritty, kitty, ghostty, foot — Adwaita Mono, size 15)"

# GTK4/Nautilus: bigger icons, bigger fonts, breathing room in sidebar + grid.
mkdir -p "$HOME/.config/gtk-4.0"
cp "$REPO_DIR/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
ok "gtk-4.0/gtk.css (sidebar row spacing, icon-grid top margin)"

gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface font-name "Adwaita Sans 13"
gsettings set org.gnome.desktop.interface document-font-name "Adwaita Sans 14"
gsettings set org.gnome.desktop.interface monospace-font-name "Adwaita Mono 13"
gsettings set org.gnome.nautilus.icon-view default-zoom-level "large"
ok "GTK text scaling (1.5x) + Nautilus icon zoom (large)"

# Cursor theme — Bibata Modern Ice, bumped up from the default 24px (GTK side;
# the Hyprland/Wayland side is set via XCURSOR_THEME/SIZE in hypr/looknfeel.lua).
gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice"
gsettings set org.gnome.desktop.interface cursor-size 32
ok "Cursor theme (Bibata-Modern-Ice, size 32)"

# Restart the desktop portals so GTK apps opened later in this session pick up
# the settings above immediately, instead of running on whatever was cached
# from before this script ran.
systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service xdg-desktop-portal-hyprland.service 2>/dev/null || true
ok "desktop portals restarted (GTK apps will reflect new settings immediately)"
