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

# Terminal fonts — Adwaita Mono at size 13, tuned for this panel's actual
# pixel density (not a naive "double everything" from a stock 1x assumption).
# foot/kitty/ghostty also carry a JetBrainsMono Nerd Font fallback so
# icon glyphs (nvim-web-devicons, mini.icons, etc.) render instead of showing
# as blank boxes — Adwaita Mono itself has no icon glyphs. Alacritty has no
# config-level fallback-font mechanism, so it doesn't get one (known gap).
mkdir -p "$HOME/.config/alacritty" "$HOME/.config/kitty" "$HOME/.config/ghostty" "$HOME/.config/foot"
cp "$REPO_DIR/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
cp "$REPO_DIR/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$REPO_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
cp "$REPO_DIR/.config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
ok "terminal fonts (alacritty, kitty, ghostty, foot — Adwaita Mono, size 13)"

# GTK4/Nautilus: bigger icons, bigger fonts, breathing room in sidebar + grid.
mkdir -p "$HOME/.config/gtk-4.0"
cp "$REPO_DIR/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
ok "gtk-4.0/gtk.css (sidebar row spacing, icon-grid top margin)"

gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
gsettings set org.gnome.desktop.interface font-name "Adwaita Sans 13"
gsettings set org.gnome.desktop.interface document-font-name "Adwaita Sans 14"
gsettings set org.gnome.desktop.interface monospace-font-name "Adwaita Mono 13"
gsettings set org.gnome.nautilus.icon-view default-zoom-level "large"
ok "GTK text scaling (1.25x) + Nautilus icon zoom (large)"

# Fresh Omarchy installs default to icon-theme "Yaru-gray", which does not
# exist in the yaru-icon-theme package actually shipped (only "Yaru",
# "Yaru-dark", and named color variants) — every icon renders broken until
# this is pinned to something real. We go one step further: Yaru-dark's
# folder icons are orange, which clashes with the monochrome Vantablack
# look, so build a local override theme that inherits everything from
# Yaru-dark except the folder icons, which get recolored dark grey.
#
# Regenerated fresh each run from the currently-installed Yaru-dark (not
# stored as static binary files in this repo) so it stays in sync with
# whatever that package actually ships. Depends on `magick` (imagemagick),
# which is a baseline Omarchy tool (its own plymouth-theming script uses it
# unconditionally), not something this repo needs to install separately.
ICON_THEME_NAME="Yaru-dark-grey-folders"
ICON_THEME_DIR="$HOME/.local/share/icons/$ICON_THEME_NAME"
YARU_DARK_DIR="/usr/share/icons/Yaru-dark"

if command -v magick &>/dev/null && [[ -d $YARU_DARK_DIR ]]; then
  rm -rf "$ICON_THEME_DIR"
  mkdir -p "$ICON_THEME_DIR"

  # Two distinct tones (not one flat color) so the icon's original
  # shading/depth survives the recolor instead of looking flat.
  DARK_TONE="#1a1a1a"
  LIGHT_TONE="#404040"

  FOLDER_FILES=$(cd "$YARU_DARK_DIR" && { find . -iname "folder*.png" -o -iname "insync-folder.png"; } | grep -v \
    "symbolic\|folder-remote\|folder-network\|folder-publicshare\|folder-templates\|folder-print\|folder-saved\|folder-tag\|folder-color\|folder-activities\|folder-github\|folder_color")

  TMP_RGB=$(mktemp --suffix=.png)
  trap 'rm -f "$TMP_RGB"' EXIT
  for f in $FOLDER_FILES; do
    DEST="$ICON_THEME_DIR/$f"
    mkdir -p "$(dirname "$DEST")"
    # Desaturate to grayscale first — colorizing the original orange
    # per-channel leaves a muddy residual hue instead of true grey — then
    # recolor, then restore the original alpha mask (transparency is lost
    # by the colorspace conversion otherwise).
    magick "$YARU_DARK_DIR/$f" -colorspace Gray +level-colors "$DARK_TONE","$LIGHT_TONE" "$TMP_RGB"
    magick "$TMP_RGB" "$YARU_DARK_DIR/$f" -compose CopyOpacity -composite "$DEST"
  done

  # index.theme: inherit everything from Yaru-dark, but only declare the
  # directories we actually populated above, with their [Directory]
  # sections copied verbatim from Yaru-dark's own index.theme.
  python3 - "$YARU_DARK_DIR/index.theme" "$ICON_THEME_DIR" "$ICON_THEME_NAME" <<'PYEOF'
import re, sys, pathlib

src_index, theme_dir, theme_name = sys.argv[1], pathlib.Path(sys.argv[2]), sys.argv[3]

wanted = sorted({
    str(p.relative_to(theme_dir).parent)
    for p in theme_dir.rglob("*.png")
})

src = pathlib.Path(src_index).read_text()
sections = re.split(r"(?m)^(\[.*\])\s*$", src)
section_map = {sections[i][1:-1]: sections[i + 1] for i in range(1, len(sections), 2)}

out = [
    "[Icon Theme]",
    f"Name={theme_name}",
    "Comment=Yaru-dark with grey folder icons instead of orange",
    "Inherits=Yaru-dark",
    "Directories=" + ",".join(wanted),
    "",
]
for d in wanted:
    if d in section_map:
        out.append(f"[{d}]")
        out.append(section_map[d].strip())
        out.append("")

(theme_dir / "index.theme").write_text("\n".join(out) + "\n")
PYEOF

  gtk-update-icon-cache -f "$ICON_THEME_DIR" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_NAME"
  ok "Icon theme ($ICON_THEME_NAME — Yaru-dark with grey instead of orange folders)"
else
  gsettings set org.gnome.desktop.interface icon-theme "Yaru-dark"
  ok "Icon theme (Yaru-dark — magick or Yaru-dark unavailable, skipped folder recolor)"
fi

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
